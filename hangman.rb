class String
  def red;            "\e[31m#{self}\e[0m" end
  def green;          "\e[32m#{self}\e[0m" end
  def blue;           "\e[34m#{self}\e[0m" end
  def pink;        "\e[35m#{self}\e[0m" end
  def cyan;           "\e[36m#{self}\e[0m" end
  def yellow;           "\e[33m#{self}\e[0m" end
end

class Keyword
  attr_reader :keyword, :keyword_hide_info
  def initialize
    @keyword = get_keyword('5desk.txt')
    @keyword_hide_info = Hash.new
    @keyword.split('').each do |letter|
      @keyword_hide_info[letter] = 'hidden'
    end
  end

  def get_keyword file
    keyword = ''
    until keyword.length > 5 && keyword.length < 12
      keyword = File.readlines(file,).sample.strip
    end
    keyword
  end

  def show_hidden_keyword
    hidden_keyword = ''
    @keyword.split('').each do |letter|
      info = @keyword_hide_info[letter]
      info == 'hidden' ? hidden_keyword += '_ ' : hidden_keyword += letter + ' '
    end
    puts hidden_keyword
  end

  def show_keyword
    puts @keyword
  end
end

class Game

  def initialize
    @alphabet = Alphabet.new
    @keyword = Keyword.new
  end

  def check_answer answer
    keyword = @keyword.keyword
    @keyword.keyword_hide_info[answer] = 'visible'
  end

  def ask_letter
    answer = ''
    until answer.length == 1 && answer =~ /[a-zA-Z]/
      puts 'Harf Gir.'
      answer = gets.chomp
    end
    answer.upcase
  end

  def play_round
    @keyword.show_hidden_keyword
    puts ''
    @alphabet.show
    puts ''
    @keyword.show_keyword
    answer = ask_letter
    check_answer(answer)
    @alphabet.change_leter_color(answer)
    @keyword.show_hidden_keyword
    puts ''
    @alphabet.show

  end
end



class Alphabet
  def initialize
    @alphabet_array = ('A'..'Z').to_a
    @alphabet_hash = Hash.new
    @alphabet_array.each do |letter|
      @alphabet_hash[letter] = 'red'
    end
  end

  def show
    alphabet_string = ''
    @alphabet_hash.each do |letter,color|

      color == 'red' ? alphabet_string += letter.red + ' ' : alphabet_string += letter.green + ' '
    end
    puts alphabet_string
  end

  def change_leter_color(letter)
    letter = letter.upcase
    @alphabet_hash[letter] == 'red' ? @alphabet_hash[letter] = 'green' : @alphabet_hash[letter] = 'red'
  end

end

game = Game.new

game.play_round