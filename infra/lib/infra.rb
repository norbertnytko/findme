module Infra
  module Types
    include Dry.Types

    UUID = Types::Strict::String.constrained(
      format: /\A[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-4[0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}\z/i
    )
  end

  class Event < RubyEventStore::Event; end

  class Command < Dry::Struct
    Invalid = Class.new(StandardError)

    def self.new(*)
      super
    rescue Dry::Struct::Error => doh
      raise Invalid, doh
    end
  end

  class AggregateRootRepository
    def initialize(event_store)
      @repository = AggregateRoot::Repository.new(event_store)
    end

    def with_aggregate(aggregate_class, aggregate_id, &block)
      @repository.with_aggregate(
        aggregate_class.new(aggregate_id),
        stream_name(aggregate_class, aggregate_id),
        &block
      )
    end

    def stream_name(aggregate_class, aggregate_id)
      "#{aggregate_class.name}$#{aggregate_id}"
    end
  end

  class Form
    include ActiveModel::Model
    include ActiveModel::Attributes

    attr_accessor :existing_data

    attribute :aggregate_id

    class << self
      def commands
        @commands ||= []
      end

      def command(command_class, fields: nil)
        commands << { command_class: command_class, fields: fields }
      end
    end

    def submit(command_bus)
      return false unless valid?

      process_commands.each do |command|
        begin
          command_bus.(command)
        rescue => e
          errors.add(:base, e.message)
          return false
        end
      end

      true
    end

    def persisted?
      existing_data.present?
    end

    def new_record?
      !persisted?
    end

    private

    def process_commands
      self.class.commands.flat_map do |command_info|
        command_attrs = command_info[:fields].map do |field| 
          [field, public_send(field)] if should_produce_command?(field)
        end.compact.to_h

        command_attrs.present? ? [command_info[:command_class].new(command_attrs.merge(aggregate_id: aggregate_id))] : []
      end
    end

    def should_produce_command?(field)
      return true if existing_data.nil?

      existing_data[field.to_s] != public_send(field)
    end
  end
end
