# frozen_string_literal: true

require 'dotenv'
require 'ruby/openai'
require 'csv'

Dotenv.load

openai = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])

text_array = []
embedding_array = []

Dir.glob('training-data/*.txt') do |file|
  text = File.read(file).dump
  text_array << text
end

text_array.each do |text|
  response = openai.embeddings(
    parameters: {
      model: 'text-embedding-ada-002',
      input: text
    }
  )

  embedding = response['data'][0]['embedding']

  embedding_hash = { embedding: embedding, text: text }
  embedding_array << embedding_hash
end

CSV.open('embeddings.csv', 'w') do |csv|
  csv << %i[embedding text]
  embedding_array.each do |obj|
    csv << [obj[:embedding], obj[:text]]
  end
end
