require 'spec_helper'

describe BookSorter do
  describe 'split_dewey' do
    it 'seperates dewey decimal id into an array' do
      result = %w(500 510 513 513.5 513.54).freeze
      expect(BookSorter::Client.split_dewey('513.54')).to eq(result)
    end
  end

  describe 'gen_path' do
    it 'generates a simple path' do
      dewey_codes = %w(500 510 513 513.5 513.54).freeze
      wordings = [
        'Literature', 'American And Canadian', 'Fiction',
        '20th Century', '1945-1999'
      ].freeze
      authors = ['Martin, George R. R.'].freeze
      result =
        'Books/500 - Literature/510 - American And Canadian/513 - ' +
        'Fiction/513.5 - 20th Century/513.54 - 1945-1999/Martin, George R. R.'

      expect(BookSorter::Client.gen_path(
        dewey_codes, wordings, authors
      )).to eq(result)
    end
  end
end
