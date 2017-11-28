$LOAD_PATH << '.'

require 'gosu'
require_relative 'player'
require_relative 'timer'
require_relative 'bomb'
require_relative 'boss'

class GameWindow < Gosu::Window
  def initialize
    super(256, 240, true)
    self.caption = "Bomberman v.0.1"

    @option = 1
    @image_index = 0
    @estado = :title
    @font = Gosu::Font.new(40)

    @bg_option1 = Gosu::Image.new("images/op1.png")
    @bg_option2 = Gosu::Image.new("images/op2.png")
    @bg_option3 = Gosu::Image.new("images/op3.png")
    @bg_battle = Gosu::Image.new("images/battle_map.png")
    @win = Gosu::Image.new("images/YouWin.png")
    @tutorial = Gosu::Image.new("images/tutorial.png")
    @creditos = Gosu::Image.new("images/creditos.png")

    @gameover = []
    for i in 0..10 do @gameover[i] = Gosu::Image.new("images/gameOver1.png") end
    for i in 11..20 do @gameover[i] = Gosu::Image.new("images/gameOver2.png") end

    @titleScreenOst = Gosu::Song.new("audio/TitleScreen.wav")
    @optionOst = Gosu::Sample.new("audio/opçãoSom.wav")
    @battleOst = Gosu::Song.new("audio/Battle.wav")
    @danoOst = Gosu::Sample.new("audio/dano.ogg")
    @gameoverOst = Gosu::Song.new("audio/GameOver.wav")
    @winnerOst = Gosu::Song.new("audio/win.wav")

    @bombs = []
  end

  def update
    case @estado
    when :title
      @titleScreenOst.play(true)
    when :game
      @timer.relogio
      @battleOst.play(true)
      #Movimentação do PLAYER
      @player.move_up if button_down? (Gosu::KbW)
      @player.move_down if button_down? (Gosu::KbS)
      @player.move_left if button_down? (Gosu::KbA)
      @player.move_right if button_down? (Gosu::KbD)
      #Movimentação do BOSS
      @boss.move_up if button_down? (Gosu::KbUp)
      @boss.move_down if button_down? (Gosu::KbDown)
      @boss.move_left if button_down? (Gosu::KbLeft)
      @boss.move_right if button_down? (Gosu::KbRight)
      #Colisão PLAYER-BOSS
      distanciaBoss = Gosu::distance(@player.x, @player.y, @boss.x, @boss.y)
      if distanciaBoss + 15 < @player.radius + @boss.radius then
        @player.y += 35 if button_down? (Gosu::KbW)
        @player.y += 35 if button_down? (Gosu::KbDown)
        @player.y -= 35 if button_down? (Gosu::KbS)
        @player.y -= 35 if button_down? (Gosu::KbUp)
        @player.x += 35 if button_down? (Gosu::KbA)
        @player.x += 35 if button_down? (Gosu::KbRight)
        @player.x -= 35 if button_down? (Gosu::KbD)
        @player.x -= 35 if button_down? (Gosu::KbLeft)
        #Evitar que o player seja jogado para fora do mapa
        @player.y = 36 if @player.y < 36
        @player.y = 196 if @player.y > 196
        @player.x = 30 if @player.x < 30
        @player.x = 224 if @player.x > 224
        @player.vidas -= 1
        @danoOst.play
      end
      #Colisão BOMBA-BOSS
      @bombs.each do |bomb|
        @distanciaBomba = Gosu::distance(bomb.x, bomb.y, @boss.x, @boss.y)
        if @distanciaBomba - 10 < bomb.radius + @boss.radius then
          if bomb.finished == true then
            @boss.damaged = true #trocar o sprite
            @boss.vidas -= 1
            @image_index = 0 #reiniciar animação
          end
        end
      end
      #Condições que levam ao GAMEOVER
      if @player.vidas == 0 || @timer.tempo == 0 then
        @estado = :over
      end
      #Condições que levam a vitória
      if @boss.vidas == 0
        @estado = :winner
      end
    when :over
      @battleOst.stop
      @gameoverOst.play(true)
    when :winner
      @battleOst.stop
      @winnerOst.play(true)
    end
  end

  def draw
    case @estado
    when :title
      @bg_option1.draw(0, 0, 0) if @option == 1
      @bg_option2.draw(0, 0, 0) if @option == 2
      @bg_option3.draw(0, 0, 0) if @option == 3
    when :game
      @bg_battle.draw(0, 0, 0)
      @player.draw
      @boss.draw
      @timer.draw
      @bombs.each do |bomb|
        if bomb.finished == false
          bomb.draw
        else
          @bombs.delete(bomb)
        end
      end
      #Reutilizando o array @gameover para deixar a animação de dano mais lenta.
      if @boss.damaged == true
        if @image_index < @gameover.count
          @image_index += 1
        else
          @boss.damaged = false
        end
      end
    when :over
      @font.draw("GAME", 18, 105, 1, 1, 1, 0xffffff00)
      @font.draw("OVER", 18, 135, 1, 1, 1, 0xffffff00)
      #Animação do GAMEOVER
      if @image_index < @gameover.count
        @gameover[@image_index].draw(0, 0, 0)
        @image_index += 1
      else
        @image_index = 0
      end
    when :winner
      @font.draw("VOCÊ", 18, 105, 1, 1, 1, 0xffffff00)
      @font.draw("VENCEU", 9, 135, 1, 1, 1, 0xffffff00)
      @win.draw(0, 0, 0)
    when :tutorial
      @tutorial.draw(0, 0, 0)
    when :credits
      @creditos.draw(0, 0, 0)
    end
  end

  def button_down(id)
    case @estado
    when :title
      case id
      when Gosu::KbW
        @optionOst.play
        if @option > 1 then @option -= 1 elsif @option == 1 then @option = 3 end
      when Gosu::KbUp
        @optionOst.play
        if @option > 1 then @option -= 1 elsif @option == 1 then @option = 3 end
      when Gosu::KbS
        @optionOst.play
        if @option < 3 then @option += 1 elsif @option == 3 then @option = 1 end
      when Gosu::KbDown
        @optionOst.play
        if @option < 3 then @option += 1 elsif @option == 3 then @option = 1 end
      when Gosu::KbReturn
        if @option == 1 then
          @titleScreenOst.stop
          @optionOst.play
          @estado = :game
          @bombs = []
          @timer = Timer.new
          @player = Player.new(self)
          @boss = Boss.new(self)
        end
        if @option == 2 then
          @estado = :tutorial
        end
        if @option == 3 then
          @estado = :credits
        end
      when Gosu::KbEscape
        exit
      end
    when :game
      case id
      when Gosu::KbSpace
          @bombs.push Bomb.new(@player.x, @player.y + 12) if @bombs.length < @player.bomb_limit
      when Gosu::KbEscape
          @estado = :title
      end
    when :over
      case id
      when Gosu::KbEscape
          @estado = :title
      end
    when :winner
      case id
      when Gosu::KbEscape
          @estado = :title
      end
    when :tutorial
      case id
      when Gosu::KbEscape
          @estado = :title
      end
    when :credits
      case id
      when Gosu::KbEscape
          @estado = :title
      end
    end
  end

end

window = GameWindow.new
window.show
