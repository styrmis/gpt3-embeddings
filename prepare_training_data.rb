# frozen_string_literal: true

require 'pathname'
require 'tiktoken_ruby'

require 'pry'

PROJECT_ROOT_PATH_NAME = File.expand_path('~/Dropbox/100-199\ Personal/101\ Personal\ System/60-69\ Projects/61\ General/101.61.019\ 2023-05-07\ Andri\ bot/')

SOURCE_DATA_PATH = Pathname(PROJECT_ROOT_PATH_NAME) + 'training-data'

SOURCE_DATA_FILE_PATHS = Dir[SOURCE_DATA_PATH + '*.txt']

WORKDIR_PATH = Pathname(File.expand_path(__dir__))

TRAINING_DATA_PATH = WORKDIR_PATH + 'training-data'

ENCODER = Tiktoken.get_encoding("cl100k_base")

def n_tokens(str)
  encode(str).size
end

def encode(str)
  ENCODER.encode(str)
end

def decode(tokens)
  ENCODER.decode(tokens)
end

SOURCE_DATA_FILE_PATHS.each do |path|
  file_name = File.basename(path, '.txt')

  content = File.read(path)

  with_newlines_replaced = content.tr("\n", ' ')

  as_tokens = encode(with_newlines_replaced)

  as_tokens.each_slice(8191).each_with_index do |tokens, i|
    slice_file_path = TRAINING_DATA_PATH + "#{file_name}_#{format('%03d', i + 1)}.txt"

    decoded = decode(tokens)

    File.write(slice_file_path, decoded)
  end

  # binding.pry
end
