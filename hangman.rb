require 'json'
class String
  def red;            "\e[31m#{self}\e[0m" end
  def green;          "\e[32m#{self}\e[0m" end
  def blue;           "\e[34m#{self}\e[0m" end
  def pink;        "\e[35m#{self}\e[0m" end
  def cyan;           "\e[36m#{self}\e[0m" end
  def yellow;           "\e[33m#{self}\e[0m" end
end

class Keyword
  attr_accessor :keyword, :keyword_hide_info
  def initialize
    @keyword = get_keyword('5desk.txt').downcase
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
  attr_accessor :life
  def initialize
    @alphabet = Alphabet.new
    @keyword = Keyword.new
    @life = 5
  end

  def save_game
    all_data = Hash.new
    all_data['life'] = @life
    all_data['alphabet_hash'] = @alphabet.alphabet_hash
    all_data['keyword_hide_info'] = @keyword.keyword_hide_info
    all_data['keyword'] = @keyword.keyword
    # @life
    # @alphabet.alphabet_hash
    # @keyword.keyword_hide_info
    # @keyword.keyword
    File.open('save.json','w') do |f|
      f.write(all_data.to_json)
    end
    puts 'Oyun Kaydedildi!'
  end

  def load_game
    if File.exist?('save.json')
      File.open('save.json') do |f|
        all_data = JSON.parse(f.read) 
        puts hash
        @life = all_data['life']
        @alphabet.alphabet_hash = all_data['alphabet_hash']
        @keyword.keyword_hide_info = all_data['keyword_hide_info']
        @keyword.keyword = all_data['keyword']
      end
    end
  end

  def check_answer answer
    keyword = @keyword.keyword
    @keyword.keyword_hide_info.key?(answer) ? @keyword.keyword_hide_info[answer] = 'visible' : false
  end

  def ask_letter
    answer = ''
    until (answer.length == 1 && answer =~ /[a-zA-Z]/ && @alphabet.alphabet_hash[answer.upcase ]== 'red') || answer.length == 4
      puts 'Lütfen Daha Önce Girmediğiniz Bir Harf Girin.'
      answer = gets.chomp
    end
    answer.downcase
  end

  def play_round
    @keyword.show_keyword
    @keyword.show_hidden_keyword
    puts ''
    @alphabet.show
    puts ''
    puts "Hak: #{@life}"
    answer = ask_letter
    if answer == 'save'
      save_game
    elsif answer == 'load'
      load_game
    else
    @life -= 1 if check_answer(answer) == false
    @alphabet.change_leter_color(answer)
    end
  end

  def game_lost?
    true if @life == 0
  end

  def game_won?
    game_won = true
    @keyword.keyword_hide_info.each do |letter,info|
      game_won = false if info == 'hidden'
    end
    game_won
  end

  def player_won
    puts 'Oyunu Kazandınız!'
    puts "Kelimeniz: #{@keyword.keyword}'idi."
    new_game if play_again?
  end

  def player_lost
    puts 'Oyunu Kaybettiniz!'
    puts "Kelimeniz: #{@keyword.keyword}'idi."
    new_game if play_again?
  end

  def new_game
    game = Game.new
    game.play_game
  end

  def play_again?
    answer = ''
    until answer.length == 1 && (answer == 'y' || answer == 'n')
      puts 'Tekrar Oynamak Ister Mısınız? (Y/N)'
      answer = gets.chomp.downcase
    end
    answer == 'y' ? true : false
  end

  def play_game
    while true
      if game_won?
        player_won
        break
      elsif game_lost?
        player_lost
        break
      else
        play_round
      end
    end
  end
end


class Alphabet
  attr_accessor :alphabet_hash
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
game.play_game