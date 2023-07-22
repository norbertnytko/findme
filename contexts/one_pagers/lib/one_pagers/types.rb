module OnePagers
  module Types
    include ::Infra::Types

    Theme = Types::String.enum("light", "dark", "cupcake", "bumblebee", "emerald", "corporate", "synthwave", "retro", "cyberpunk",
      "valentine", "halloween", "garden", "forest", "aqua", "lofi", "pastel", "fantasy", "wireframe", "black", "luxury",
      "dracula", "cmyk", "autumn", "business", "acid", "lemonade", "night", "coffee", "winter")
    Position = Types::Strict::Integer.constrained(gt: 0)
  end
end
