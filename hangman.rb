require 'json'
class String
  def red;            "\e[31m#{self}\e[0m" end
  def green;          "\e[32m#{self}\e[0m" end
end

class Keyword
  attr_accessor :keyword, :keyword_hide_info
  def initialize
    @keyword = get_keyword('5desk.txt').downcase #Gets 5-12 letter keyword.
    @keyword_hide_info = Hash.new # Create a hash that provides info about letter's info
    @keyword.split('').each do |letter|
      @keyword_hide_info[letter] = 'hidden'
    end
  end

  def get_keyword file #Gets a new keyword
    keyword = ''
    until keyword.length > 5 && keyword.length < 12
      keyword = File.readlines(file,).sample.strip
    end
    keyword
  end

  def show_hidden_keyword # Shows keyword like: _ _ a _ c _ b if info == hidden
    hidden_keyword = ''
    @keyword.split('').each do |letter|
      info = @keyword_hide_info[letter]
      info == 'hidden' ? hidden_keyword += '_ ' : hidden_keyword += letter + ' '
    end
    puts hidden_keyword
  end

  def show_keyword # Prints keyword
    puts @keyword
  end
end

class Alphabet
  attr_accessor :alphabet_hash
  def initialize
    @alphabet_array = ('A'..'Z').to_a
    @alphabet_hash = Hash.new         # Creates a Hash of all letters
    @alphabet_array.each do |letter|
      @alphabet_hash[letter] = 'red'  # Mark them as Red
    end
  end

  def show # Shows letter green if used
    alphabet_string = ''
    @alphabet_hash.each do |letter,color|

      color == 'red' ? alphabet_string += letter.red + ' ' : alphabet_string += letter.green + ' '
    end
    puts alphabet_string
  end

  def change_leter_color(letter) # Change letter's color
    letter = letter.upcase
    @alphabet_hash[letter] == 'red' ? @alphabet_hash[letter] = 'green' : @alphabet_hash[letter] = 'red'
  end

end


class Game
  attr_accessor :life
  def initialize
    @alphabet = Alphabet.new
    @keyword = Keyword.new
    @life = 9
  end

  def save_game #Saves all important data to json file.
    all_data = Hash.new
    all_data['life'] = @life
    all_data['alphabet_hash'] = @alphabet.alphabet_hash
    all_data['keyword_hide_info'] = @keyword.keyword_hide_info
    all_data['keyword'] = @keyword.keyword
    File.open('save.json','w') do |f|
      f.write(all_data.to_json)
    end
    puts 'Oyun Kaydedildi!'
  end

  def load_game # Load all important data from json file.
    if File.exist?('save.json')
      File.open('save.json') do |f|
        all_data = JSON.parse(f.read) 
        @life = all_data['life']
        @alphabet.alphabet_hash = all_data['alphabet_hash']
        @keyword.keyword_hide_info = all_data['keyword_hide_info']
        @keyword.keyword = all_data['keyword']
      end
    else
      puts 'Kayıt Dosyası Bulunmamakta!'
    end
  end

  def check_answer answer # If answer is true, sets letter's info to visible.
    keyword = @keyword.keyword
    @keyword.keyword_hide_info.key?(answer) ? @keyword.keyword_hide_info[answer] = 'visible' : false
  end

  def ask_letter # Ask letter or save/load
    answer = ''
    until (answer.length == 1 && answer =~ /[a-zA-Z]/ && @alphabet.alphabet_hash[answer.upcase ]== 'red') || answer.length == 4
      puts 'Lütfen Daha Önce Girmediğiniz Bir Harf Girin.'
      puts 'Kayıt Kaydetmek İçin "Save" Yüklemek İçin "Load" yazın.'
      answer = gets.chomp
    end
    answer.downcase
  end

  def play_round #One round
    puts `clear`
    @keyword.show_hidden_keyword
    puts ''
    @alphabet.show
    puts ''
    puts "Hak: #{@life}"
    answer = ask_letter
    if answer.downcase == 'save'
      save_game
    elsif answer.downcase == 'load'
      load_game
    else
    @life -= 1 if check_answer(answer) == false
    @alphabet.change_leter_color(answer)
    end
  end

  def game_lost?
    true if @life == 0
  end

  def game_won? # Check every key
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

  def play_again? # Asks for y/n
    answer = ''
    until answer.length == 1 && (answer == 'y' || answer == 'n')
      puts 'Tekrar Oynamak Ister Mısınız? (Y/N)'
      answer = gets.chomp.downcase
    end
    answer == 'y' ? true : false
  end

  def play_game # Play one game
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




game = Game.new
game.play_game