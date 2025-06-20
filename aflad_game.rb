# Ace, Flower, Love & Diamond Card Game
# A custom card game implementation in Ruby

require 'set'
# Uncomment for graphical version:
# require 'ruby2d'

# Card class represents a single playing card
class Card
  SUITS = {
    ace: 'Ace',
    flower: 'Flower',
    love: 'Love',
    diamond: 'Diamond'
  }.freeze

  RANKS = (1..10).to_a.freeze

  attr_reader :suit, :rank, :name

  def initialize(suit, rank)
    @suit = suit
    @rank = rank
    @name = "#{SUITS[suit]} #{rank}"
  end

  def to_s
    name
  end

  # Compare cards based on game rules
  def <=>(other)
    # Special interactions: Love beats Diamond regardless of rank
    return 1 if suit == :love && other.suit == :diamond
    return -1 if suit == :diamond && other.suit == :love

    # Otherwise compare by rank
    rank <=> other.rank
  end
end

# Deck class represents a collection of cards
class Deck
  attr_reader :cards

  def initialize
    @cards = []
    build_deck
    shuffle
  end

  def build_deck
    Card::SUITS.keys.each do |suit|
      Card::RANKS.each do |rank|
        @cards << Card.new(suit, rank)
      end
    end
  end

  def shuffle
    @cards.shuffle!
  end

  def deal(num = 1)
    @cards.pop(num)
  end

  def empty?
    @cards.empty?
  end

  def remaining
    @cards.size
  end
end

# Player class represents a game participant
class Player
  attr_reader :name, :hand, :score

  def initialize(name)
    @name = name
    @hand = []
    @score = 0
  end

  def receive_cards(new_cards)
    @hand += new_cards
  end

  def play_card(index = 0)
    @hand.delete_at(index)
  end

  def has_cards?
    !@hand.empty?
  end

  def increment_score
    @score += 1
  end

  def to_s
    "#{name} (Score: #{score})"
  end
end

# Game class manages the game logic and flow
class Game
  def initialize(player_count = 2)
    @players = []
    @deck = Deck.new
    @round = 0
    @game_over = false

    setup_players(player_count)
    deal_initial_cards
  end

  def setup_players(count)
    count.times do |i|
      print "Enter name for Player #{i + 1}: "
      name = gets.chomp
      @players << Player.new(name.empty? ? "Player #{i + 1}" : name)
    end
  end

  def deal_initial_cards
    cards_per_player = 5
    @players.each do |player|
      player.receive_cards(@deck.deal(cards_per_player))
    end
  end

  def play_round
    @round += 1
    puts "\n=== Round #{@round} ==="

    played_cards = []
    @players.each_with_index do |player, index|
      display_player_hand(player)
      card_index = select_card_index(player)
      played_card = player.play_card(card_index)
      played_cards << { player: player, card: played_card }
      puts "#{player.name} plays: #{played_card}"
    end

    determine_round_winner(played_cards)
    check_game_over
  end

  def select_card_index(player)
    loop do
      print "#{player.name}, select a card to play (1-#{player.hand.size}): "
      input = gets.chomp.to_i - 1
      return input if input.between?(0, player.hand.size - 1)
      puts "Invalid selection. Please try again."
    end
  end

  def determine_round_winner(played_cards)
    winning_play = played_cards.max_by { |play| play[:card] }
    winner = winning_play[:player]
    winner.increment_score
    puts "\n#{winner.name} wins the round with #{winning_play[:card]}!"
    display_scores
  end

  def check_game_over
    @game_over = @players.any? { |p| !p.has_cards? }
    if @game_over
      determine_game_winner
    end
  end

  def determine_game_winner
    max_score = @players.map(&:score).max
    winners = @players.select { |p| p.score == max_score }

    puts "\n=== Game Over ==="
    if winners.size == 1
      puts "#{winners.first.name} wins the game with #{max_score} points!"
    else
      puts "It's a tie between #{winners.map(&:name).join(' and ')} with #{max_score} points each!"
    end
  end

  def display_player_hand(player)
    puts "\n#{player.name}'s hand:"
    player.hand.each_with_index do |card, index|
      puts "#{index + 1}. #{card}"
    end
  end

  def display_scores
    puts "\nCurrent Scores:"
    @players.each do |player|
      puts "#{player.name}: #{player.score}"
    end
  end

  def play
    until @game_over
      play_round
    end
  end
end

# Main game execution
if __FILE__ == $0
  puts "🎴 Welcome to Ace, Flower, Love & Diamond! 🎴"
  puts "Game Rules:"
  puts "- Each suit has cards ranked 1-10"
  puts "- Normal play: Higher rank wins"
  puts "- Special rule: Love beats Diamond regardless of rank"
  puts "- Each player gets 5 cards"
  puts "- Highest score when cards run out wins"

  print "\nEnter number of players (default 2): "
  player_count = gets.chomp.to_i
  player_count = 2 if player_count < 2

  game = Game.new(player_count)
  game.play
end
