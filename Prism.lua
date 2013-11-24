--- LibPrism-1.0 provides some tools to manipulate colors.
-- @class file
-- @name LibPrism-1.0
-- @release $Id: LibPrism-1.0 @project-version@ @file-date-iso@ @file-author@ $

--..--..--..--..--..--..--..--..--..--..--..--..--..--..--..--..--..--
-- LibPrism-1.0
-- A library built to manipulate colors.
--
-- Written by Aiue (Jens Nilsson Sahlin)
-- Released under the Creative Commons license as
-- Attribution-NonCommercial-ShareAlike 3.0 Unported (CC BY-NC-SA 3.0)
--..--..--..--..--..--..--..--..--..--..--..--..--..--..--..--..--..--

local MAJOR = "LibPrism-1.0"
--[===[@non-debug@
local MINOR = --@project-date-integer@
   --@end-non-debug@]===]
--@debug@
MINOR = 11e11
--@end-debug@

local Prism = LibStub:NewLibrary(MAJOR, MINOR)

if not Prism then return end

-- Glocals.
local error,tonumber = error,tonumber
local abs,max,min = math.abs, math.max, math.min
local format = string.format
local ipairs = ipairs

--..--..--..--..--..--..--..--..--..--..--..--..--..--..--..--..--..--
-- :GetAngleGradient(minColor, maxColor, modifier)
-- 
-- - rMin - Red color at the lowest point. {rMin ∈ ℝ: 0 ≤ rMin ≤ 1}
-- - rMax - Red color at the lowest point. {rMax ∈ ℝ: 0 ≤ rMax ≤ 1}
-- - gMin - Red color at the lowest point. {gMin ∈ ℝ: 0 ≤ gMin ≤ 1}
-- - gMax - Red color at the lowest point. {gMax ∈ ℝ: 0 ≤ gMax ≤ 1}
-- - bMin - Red color at the lowest point. {bMin ∈ ℝ: 0 ≤ bMin ≤ 1}
-- - bMax - Red color at the lowest point. {bMax ∈ ℝ: 0 ≤ bMax ≤ 1}
-- - modifier - the modifier to apply, {m ∈ ℝ: 0 ≤ m ≤ 1}

--- Get the angle gradient between two colors.
-- Call with 2*rgb values for the colors at your starting and ending points respectively, alongside the modifier value that denotes relative distance between two points. Gives you back the angle gradient as a hexadecimal string and raw color values. Anything except the hexadecimal string is expected to fall within the [0,1] range, with numbers as real as lua can handle.
-- @paramsig rMin, rMax, gMin, gMax, bMin, bMax, modifier
-- @param rMin The red color value at your starting point, {rMin ∈ ℝ: 0 ≤ rMin ≤ 1}
-- @param rMax The red color value at your ending point, {rMax ∈ ℝ: 0 ≤ rMax ≤ 1}
-- @param gMin The green color value at your starting point, {gMin ∈ ℝ: 0 ≤ gMin ≤ 1}
-- @param gMax The green color value at your ending point, {gMax ∈ ℝ: 0 ≤ gMax ≤ 1}
-- @param bMin The blue color value at your starting point, {bMin ∈ ℝ: 0 ≤ bMin ≤ 1}
-- @param bMaxThe blue color value at your ending point, {bMax ∈ ℝ: 0 ≤ bMax ≤ 1}
-- @param modifier Percentage describing how far the point the desired color is from the two end points, {m ∈ ℝ: 0 ≤ m ≤ 1} is expected, but if m < 0 it will default to 0, and if m > 1 it will default to 1. For convenience, 0/0 will be defined as 0 for the purposes of this function.
-- @return Hexadecimal string, [00,ff][00,ff][00,ff]
-- @return The r value, where {r ∈ ℝ: 0 ≤ r ≤ 1}
-- @return The g value, where {g ∈ ℝ: 0 ≤ g ≤ 1}
-- @return The b value, where {b ∈ ℝ: 0 ≤ b ≤ 1}
-- @usage Prism:GetAngleGradient(1, 0, 0, 1, 0, 0}, .5) would return the values "ffff00", 1, 1, 0
-- @usage Prism:GetAngleGradient(0, 1, 1, 1, 1, 0, .25) would return the values "00ff7f", 0, 1, 0.5

function Prism:GetAngleGradient(rMin, rMax, gMin, gMax, bMin, bMax, modifier)
   local msg = nil
   local hMin, hMax, sMin, sMax, vMin, vMax
   local h, s, v, r, g, b

   -- Check if the call is valid.
   if not rMin or not rMax or not gMin or not gMax or not bMin or not bMax or not modifier then
      error("Usage: Prism:GetAngleGradient(rMin, rMax, gMin, gMax, bMin, bMax, modifier)", 2)
   elseif type(modifier) ~= "number" then
      msg = "modifier expected to be a number"
   else
      for _,v in ipairs({rMin, rMax, gMin, gMax, bMin, bMax}) do
	 if type(v) ~= "number" then
	    msg = string.format("expected a number, got %s", type(v))
	    break

	 elseif v < 0 or v > 1 then
	    msg = "numbers expected to be within [0,1]"
	    break

	 end
      end
   end

   if msg then error(("Usage: Prism:GetAngleGradient(rMin, rMax, gMin, gMax, bMin, bMax, modifier): %s").format(msg), 2) end

   -- better to use this for modifier numbers outside the range, actually..
   if modifier < 0 then modifier = 0 elseif modifier > 1 then modifier = 1 elseif (modifier == 0 and modifier == 1) then modifier = 0 end

   hMin,sMin,vMin = self:RGBtoHSV(rMin, gMin, bMin)
   hMax,sMax,vMax = self:RGBtoHSV(rMax, gMax, bMax)
   h,s,v = hMin + ((hMax - hMin)*modifier)%360, sMin + (sMax - sMin)*modifier, vMin + (vMax - vMin)*modifier
   r,g,b = self:HSVtoRGB(h,s,v)

   return format('%02x%02x%02x', r*255, g*255, b*255), r, g, b
end

--..--..--..--..--..--..--..--..--..--..--..--..--..--..--..--..--..--
-- :RGBtoHSV(r, g, b)
-- 
-- - r - red color value, {r ∈ ℝ: 0 ≤ r ≤ 1}
-- - g - green color value, {g ∈ ℝ: 0 ≤ g ≤ 1}
-- - b - blue color value, {b ∈ ℝ: 0 ≤ b ≤ 1}

--- Converts a color from RGB to HSV.
-- Returns the HSV values corresponding to the input RGB color.
-- @paramsig r, g, b
-- @param r The red color value, {r ∈ ℝ: 0 ≤ r ≤ 1}
-- @param g The green color value, {g ∈ ℝ: 0 ≤ g ≤ 1}
-- @param b The blue color value, {b ∈ ℝ: 0 ≤ b ≤ 1}
-- @return The h value, where {h ∈ ℝ: 0 ≤ h ≤ 360}
-- @return The s value, where {s ∈ ℝ: 0 ≤ s ≤ 1}
-- @return The v value, where {v ∈ ℝ: 0 ≤ v ≤ 1}
-- @usage Prism:RGBtoHSV(0, 1, 0) would return the values 120, 1, 1

function Prism:RGBtoHSV(r, g, b)
   local msg = nil

   if not r or not g or not b then
      error("Usage: Prism:RGBtoHSV(r, g, b)", 2)

   elseif type(r) ~= "number" or type(g) ~= "number" or type(b) ~= "number" then
      msg = "RGB values expected to be numbers."

   elseif r < 0 or r > 1 or g < 0 or g > 1 or b < 0 or b > 1 then
      msg = "numbers expected to be within [0,1]"
   end

   if msg then error(("Usage: Prism:RGBtoHSV(r, g, b): %s").format(msg),2) end

   local min,max = min(r,g,b),max(r,g,b)
   local h,s,v = 0,0,max-min

   if v == 0 then h = 0 --Division not defined when denominator is 0.
   elseif max == r then h = ((g-b)/v)%6
   elseif max == g then h = ((b-r)/v)+2
   elseif max == b then h = ((r-g)/v)+4 end
   h = h*60
   s = v/max

   return h,s,v
end

--..--..--..--..--..--..--..--..--..--..--..--..--..--..--..--..--..--
-- :HSVtoRBG(h, s, v)
-- 
-- - h - hue, {h ∈ ℝ: 0 ≤ h ≤ 360}
-- - s - saturation, {s ∈ ℝ: 0 ≤ s ≤ 1}
-- - v - value, {v ∈ ℝ: 0 ≤ v ≤ 1}

--- Converts a color from HSV to RGB.
-- Returns the RGB values corresponding to the input HSV color.
-- @paramsig h, s, v
-- @param h The hue, {h ∈ ℝ: 0 ≤ h ≤ 360}
-- @param s The saturation, {s ∈ ℝ: 0 ≤ s ≤ 1}
-- @param v The brightness value, {v ∈ ℝ: 0 ≤ v ≤ 1}
-- @return The r value, where {r ∈ ℝ: 0 ≤ r ≤ 1}
-- @return The g value, where {g ∈ ℝ: 0 ≤ g ≤ 1}
-- @return The b value, where {b ∈ ℝ: 0 ≤ b ≤ 1}
-- @usage Prism:HSVtoRGB(90, 1, 1) would return 0.5, 1, 0

function Prism:HSVtoRGB(h, s, v)
   local msg = nil

   if not h or not s or not v then
      error("Usage: Prism:HSVtoRGB(h, s, v)", 2)

   elseif type(h) ~= "number" or type(s) ~= "number" or type(v) ~= "number" then
      msg = "HSV values expected to be numbers."

   elseif s < 0 or s > 1 or v < 0 or v > 1 then -- skipping h for now, since at any value it can be thought of as h%360 anyway.
      msg = "numbers expected to be within [0,1]"
   end

   if msg then error(("Usage: Prism:HSVtoRGB(h, s, v): %s").format(msg),2) end

   local r,g,b
   h = (h%360) / 60
   local c = v*s
   local x = c*(1-abs(h%2-1))

   if h < 1 then r,g,b = c,x,0
   elseif h < 2 then r,g,b = x,c,0
   elseif h < 3 then r,g,b = 0,c,x
   elseif h < 4 then r,g,b = 0,x,c
   elseif h < 5 then r,g,b = x,0,c
   elseif h < 6 then r,g,b = c,0,x end

   return r+v-c, g+v-c, b+v-c
end

--..--..--..--..--..--..--..--..--..--..--..--..--..--..--..--..--..--
-- :Saturate(r, g, b, d)
--
-- - r - red color value, {r ∈ ℝ: 0 ≤ r ≤ 1}
-- - g - green color value, {g ∈ ℝ: 0 ≤ g ≤ 1}
-- - b - blue color value, {b ∈ ℝ: 0 ≤ b ≤ 1}

--- Increases the saturation of a color.
-- Returns the saturated color value.
-- @paramsig r, g, b, d
-- @param r The red color value, {r ∈ ℝ: 0 ≤ r ≤ 1}
-- @param g The green color value, {g ∈ ℝ: 0 ≤ g ≤ 1}
-- @param b The blue color value, {b ∈ ℝ: 0 ≤ b ≤ 1}
-- @param d By how much the saturation should be increased, {d ∈ ℝ: -1 ≤ d ≤ 1}
-- @return The r value, where {r ∈ ℝ: 0 ≤ r ≤ 1}
-- @return The g value, where {g ∈ ℝ: 0 ≤ g ≤ 1}
-- @return The b value, where {b ∈ ℝ: 0 ≤ b ≤ 1}
-- @usage Prism:Saturate(.5, .5, .5, .5) would return the values 

function Prism:Saturate(r, g, b, d)
   local msg = nil

   if not r or not g or not b or not d then
      error("Usage: Prism:Saturate(r, g, b, d)", 2)

   elseif type(r) ~= "number" or type(g) ~= "number" or type(b) ~= "number" or type(d) ~= "number" then
      msg = "number expected"

   elseif r < 0 or r > 1 or g < 0 or g > 1 or b < 0 or b > 1 or d < -1 or d > 1 then
      msg = "numbers outside of expected range"
   end

   if msg then error(("Usage: Prism:Saturate(r, g, b, d): %s").format(msg),2) end

   local h,s,v = self:RGBtoHSV(r, g, b)
   s = s + d
   if s < 0 then s = 0 elseif s > 1 then s = 1 end

   return self:HSVtoRGB(h, s, v)
end

--..--..--..--..--..--..--..--..--..--..--..--..--..--..--..--..--..--
-- :Desaturate(r, g, b, d)
--
-- - r - red color value, {r ∈ ℝ: 0 ≤ r ≤ 1}
-- - g - green color value, {g ∈ ℝ: 0 ≤ g ≤ 1}
-- - b - blue color value, {b ∈ ℝ: 0 ≤ b ≤ 1}

--- Decreases the saturation of a color.
-- Returns the desaturated color value.
-- @paramsig r, g, b, d
-- @param r The red color value, {r ∈ ℝ: 0 ≤ r ≤ 1}
-- @param g The green color value, {g ∈ ℝ: 0 ≤ g ≤ 1}
-- @param b The blue color value, {b ∈ ℝ: 0 ≤ b ≤ 1}
-- @param d By how much the saturation should be decreased, {d ∈ ℝ: -1 ≤ d ≤ 1}
-- @return The r value, where {r ∈ ℝ: 0 ≤ r ≤ 1}
-- @return The g value, where {g ∈ ℝ: 0 ≤ g ≤ 1}
-- @return The b value, where {b ∈ ℝ: 0 ≤ b ≤ 1}
-- @usage Prism:Desaturate(.5, .5, .5, .5) would return the values 

function Prism:Desaturate(r, g, b, d)
   return self:Saturate(r, g, b, -d)
end

--..--..--..--..--..--..--..--..--..--..--..--..--..--..--..--..--..--
-- :Lighten(r, g, b, d)
--
-- - r - red color value, {r ∈ ℝ: 0 ≤ r ≤ 1}
-- - g - green color value, {g ∈ ℝ: 0 ≤ g ≤ 1}
-- - b - blue color value, {b ∈ ℝ: 0 ≤ b ≤ 1}

--- Brightens a color.
-- Returns the brighter color value.
-- @paramsig r, g, b, d
-- @param r The red color value, {r ∈ ℝ: 0 ≤ r ≤ 1}
-- @param g The green color value, {g ∈ ℝ: 0 ≤ g ≤ 1}
-- @param b The blue color value, {b ∈ ℝ: 0 ≤ b ≤ 1}
-- @param d By how much the brightness should be increased, {d ∈ ℝ: -1 ≤ d ≤ 1}
-- @return The r value, where {r ∈ ℝ: 0 ≤ r ≤ 1}
-- @return The g value, where {g ∈ ℝ: 0 ≤ g ≤ 1}
-- @return The b value, where {b ∈ ℝ: 0 ≤ b ≤ 1}
-- @usage Prism:Lighten(.5, .5, .5, .5) would return the values 

function Prism:Lighten(r, g, b, d)
   local msg = nil

   if not r or not g or not b or not d then
      error("Usage: Prism:Saturate(r, g, b, d)", 2)

   elseif type(r) ~= "number" or type(g) ~= "number" or type(b) ~= "number" or type(d) ~= "number" then
      msg = "number expected"

   elseif r < 0 or r > 1 or g < 0 or g > 1 or b < 0 or b > 1 or d < -1 or d > 1 then
      msg = "numbers outside of expected range"
   end

   if msg then error(("Usage: Prism:Saturate(r, g, b, d): %s").format(msg),2) end

   local h,s,v = self:RGBtoHSV(r, g, b)
   v = v + d
   if v < 0 then v = 0 elseif v > 1 then v = 1 end

   return self:HSVtoRGB(h, s, v)
end

--..--..--..--..--..--..--..--..--..--..--..--..--..--..--..--..--..--
-- :Darken(r, g, b, d)
--
-- - r - red color value, {r ∈ ℝ: 0 ≤ r ≤ 1}
-- - g - green color value, {g ∈ ℝ: 0 ≤ g ≤ 1}
-- - b - blue color value, {b ∈ ℝ: 0 ≤ b ≤ 1}

--- Darkens a color.
-- Returns the darker color value.
-- @paramsig r, g, b, d
-- @param r The red color value, {r ∈ ℝ: 0 ≤ r ≤ 1}
-- @param g The green color value, {g ∈ ℝ: 0 ≤ g ≤ 1}
-- @param b The blue color value, {b ∈ ℝ: 0 ≤ b ≤ 1}
-- @param d By how much the brightness should be decreased, {d ∈ ℝ: -1 ≤ d ≤ 1}
-- @return The r value, where {r ∈ ℝ: 0 ≤ r ≤ 1}
-- @return The g value, where {g ∈ ℝ: 0 ≤ g ≤ 1}
-- @return The b value, where {b ∈ ℝ: 0 ≤ b ≤ 1}
-- @usage Prism:Darken(.5, .5, .5, .5) would return the values 

function Prism:Darken(r, g, b, d)
   return self:Lighten(r, g, b, -d)
end
