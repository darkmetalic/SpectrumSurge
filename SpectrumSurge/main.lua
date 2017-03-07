require "luafft"

abs = math.abs
new = complex.new
UpdateSpectrum = false

wave_size=3
types=1
color = {0,200,0}

Size = 1024
Frequency = 44100
length = Size / Frequency

function devide(list, factor)
  for i,v in ipairs(list) do list[i] = list[i] * factor end
end

function spectro_up(obj,sdata)

ScreenSizeW = love.graphics.getWidth()
ScreenSizeH = love.graphics.getHeight()

local MusicPos = obj:tell("samples") 
local MusicSize = sdata:getSampleCount() 

if MusicPos >= MusicSize - 1536 then wave_size=2 mtime=0 timecolor=nil love.audio.rewind(sound) end 

local List = {} 
for i= MusicPos, MusicPos + (Size-1) do
   CopyPos = i
   if i + 2048 > MusicSize then i = MusicSize/2 end 

   if sdata:getChannels()==1 then
      List[#List+1] = new(sdata:getSample(i), 0) 
    else
      List[#List+1] = new(sdata:getSample(i*2), 0) 
   end

end
spectrum = fft(List, false) 
devide(spectrum, wave_size) 
UpdateSpectrum = true
end

function spectro_show()

  love.graphics.setColor(color)

    if UpdateSpectrum then
    for i = 1, #spectrum do
      if types==1 then 	
        love.graphics.rectangle("line", i*7, ScreenSizeH, 7, -wave_size*(spectrum[i]:abs())) 
      elseif types==2 then
      	love.graphics.ellipse("line", i*7, ScreenSizeH, 7, -wave_size*(spectrum[i]:abs())) 
      elseif types==3 then
      	wave_size=7
        color={math.random(1,255),math.random(50,255),math.random(1,255)}
        love.graphics.rectangle("line", i*7, ScreenSizeH, 7, -wave_size*(spectrum[i]:abs())) 
        wave_size=2
      	color={math.random(1,255),math.random(50,255),math.random(1,255)}
      	love.graphics.rectangle("fill", i*7, ScreenSizeH, 7, -wave_size*(spectrum[i]:abs())) 
      elseif types==4 then
      	love.graphics.ellipse("fill", i*7, ScreenSizeH, 7, -wave_size*(spectrum[i]:abs())) 
      elseif types==5 then
      	love.graphics.ellipse("line", i*7, ScreenSizeH, 7, -wave_size*(spectrum[i]:abs())) 
      end
    end
    end
end


function love.load()
	love.window.setFullscreen(true)
	soundData = love.sound.newSoundData("tecdream.mp3")
	sound = love.audio.newSource(soundData)
	sound:play()
	love.mouse.setVisible(false)
end

time=0
mtime=0

function love.keyreleased(key)
   if key == "escape" then
      love.event.quit()
   end
end

function love.update(dt)

	time=time+dt
	mtime=mtime+dt

	if math.floor(time)>=10 then 
		color={math.random(1,255),math.random(50,255),math.random(1,255)} 
		types=math.random(1,5) 
		time=0
		if mtime>194 then types=math.random(4,5) end
	end

	if mtime>194.5 then timecolor=true end

	if mtime>194.5 and mtime<200 then types=4 end

	if timecolor then
	wave_size=math.random(7)
	color={math.random(255),math.random(255),math.random(255)}
	end

	spectro_up(sound,soundData)
end

function love.draw()
	spectro_show()
end

