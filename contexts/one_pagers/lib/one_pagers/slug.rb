module OnePagers
  class Slug < Dry::Struct
    attribute :value, Types::Strict::String

    def initialize(value)
      value = value.to_s.strip.downcase
      raise ArgumentError, 'Invalid slug' unless valid_slug?(value)

      super(value: value)
    end

    private

    def valid_slug?(value)
      value.match?(/\A[a-z0-9\-_]+\z/)
    end
  end
end