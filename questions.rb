# frozen_string_literal: true

require 'dotenv'
require 'ruby/openai'
require 'csv'
require 'cosine_similarity'

Dotenv.load

openai = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])

puts 'Transcript bot'
question = gets

response = openai.embeddings(
  parameters: {
    model: 'text-embedding-ada-002',
    input: question
  }
)

question_embedding = response['data'][0]['embedding']

similarity_array = []

CSV.foreach('embeddings.csv', headers: true) do |row|
  text_embedding = JSON.parse(row['embedding'])
  similarity_array << cosine_similarity(question_embedding, text_embedding)
end

index_of_max = similarity_array.index(similarity_array.max)
original_text = ''

CSV.foreach('embeddings.csv', headers: true).with_index do |row, rowno|
  original_text = row['text'] if rowno == index_of_max
end

prompt =
  "You are an AI assistant. You answer questions about the Push Bible which was an online video course created by Andri.
You will be asked questions from a customer and will answer in a helpful and friendly manner.
You will be provided information from the course under the [Content] section. The customer question
will be provided unders the [Question] section. You will answer the customer's questions based on the content.
If the users question is not answered by the content then you will respond with 'I'm sorry I don't know.'

[Content]
#{original_text}

[Question]
#{question}"

response = openai.completions(
  parameters: {
    model: 'text-davinci-003',
    prompt: prompt,
    temperature: 0.2,
    max_tokens: 500
  }
)

puts "\nResponse:\n"
puts response['choices'][0]['text'].lstrip
