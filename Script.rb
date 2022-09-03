#===============================================================================
# * Simple HUD - by FL (Credits will be apreciated)
#===============================================================================
#
# This script is for Pokémon Essentials. It displays a simple HUD with the
# party icons and some small text.
#
# To manually refresh the HUD use the line '$hud_need_refresh = true'
#
#===============================================================================
#
# To this script works, put it above main.
# 
#===============================================================================

class Spriteset_Map
  # If you wish to use a background picture, put the image path below, like
  # BGPATH="Graphics/Pictures/battleMessage". I recommend a 512x64 picture
  BGPATH=""
  USEBAR=true # Make as 'false' to don't show the blue bar
  DRAWATBOTTOM=false # Make as 'true' to draw the HUD at bottom
  UPDATESPERSECONDS=0.15  # More updates = more lag. 
  
  alias :initializeOldFL :initialize
  alias :disposeOldFL :dispose
  alias :updateOldFL :update
  
  def initialize(map=nil)
    @hud = []
    initializeOldFL(map)
    # Updates every time when a map is loaded (including connections)
    $hud_need_refresh = true 
  end
    
  def dispose
    disposeOldFL
    disposeHud
  end
  
  def update
    updateOldFL
    updateHud
  end
  
  def createHud
    return if !$Trainer # Don't draw the hud if the player wasn't defined
    return if !$game_switches[89] #test
    yposition = DRAWATBOTTOM ? Graphics.height-64 : 0
    @hud = []
    if USEBAR # Draw the blue bar
      bar=IconSprite.new(0,yposition,@viewport1)
      bar.bitmap=Bitmap.new(Graphics.width,64)
      bar.bitmap.fill_rect(Rect.new(0,0,bar.bitmap.width,bar.bitmap.height), 
          Color.new(128,128,192))  
      @hud.push(bar)
    end
    if BGPATH != "" # Draw the bar image
      bgbar=IconSprite.new(0,yposition,@viewport1)
      bgbar.setBitmap(BGPATH)
      @hud.push(bgbar)
    end
    # Draw the text
    baseColor=Color.new(72,72,72)
    shadowColor=Color.new(160,160,160)
    @hud.push(BitmapSprite.new(Graphics.width,Graphics.height,@viewport1))
    text1=_INTL("text one")
    text2=_INTL("text two")
    
    textPosition=[
      [text1,Graphics.width-240,yposition,2,baseColor,shadowColor],
      [text2,Graphics.width-240,yposition+32,2,baseColor,shadowColor]
    ]
    pbSetSystemFont(@hud[-1].bitmap)
    pbDrawTextPositions(@hud[-1].bitmap,textPosition)
    # Draw the pokémon icons
    for i in 0...$Trainer.party.size
      pokeicon=IconSprite.new(36*i-8,yposition-8,@viewport1)
      pokeicon.setBitmap(pbPokemonIconFile($Trainer.party[i]))
      pokeicon.src_rect=Rect.new(0,0,64,64)
      @hud.push(pokeicon)
    end
    for i in 0...$PokemonBag.registeredItem.size # Registered items
      itemnumber = $PokemonBag.registeredItem[i] ? 
        $PokemonBag.registeredItem[i] : 0
      # To show "?" symbol when the player has no item registered, remove the
      # below line
      next if itemnumber==0
      filename=sprintf("Graphics/Icons/item%03d",itemnumber)
      xposition = Graphics.width-48*($PokemonBag.registeredItem.size-i)
      itemicon=IconSprite.new(xposition,yposition+8,@viewport1)
      itemicon.setBitmap(filename)
      @hud.push(itemicon)
    end
    # Adjust z of every @hud sprite
    for sprite in @hud
      sprite.z+=600 
    end
  end
  
  def updateHud
    for sprite in @hud
      sprite.update
    end
  end 
  
  def disposeHud
    for sprite in @hud
      sprite.dispose
    end
    @hud.clear
  end
end

class Scene_Map
  alias :updateOldFL :update
  alias :miniupdateOldFL :miniupdate
  alias :createSpritesetsOldFL :createSpritesets
  
  UPDATERATE = (Spriteset_Map::UPDATESPERSECONDS>0) ? 
      (Graphics.frame_rate/Spriteset_Map::UPDATESPERSECONDS).floor : 0x3FFF 
    
  def update
    updateOldFL
    checkAndUpdateHud
  end
  
  def miniupdate
    miniupdateOldFL
    checkAndUpdateHud
  end
  
  def createSpritesets
    createSpritesetsOldFL
    checkAndUpdateHud
  end  
  
  def checkAndUpdateHud
    $hud_need_refresh = (Graphics.frame_count%UPDATERATE==0 ||
      $hud_need_refresh)
    if $hud_need_refresh
      for s in @spritesets.values
        s.disposeHud
        s.createHud
      end
      $hud_need_refresh = false
    end
  end
end