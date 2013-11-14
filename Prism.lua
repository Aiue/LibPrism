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

local MAJOR, MINOR = "LibPrism-1.0", 1
local Prism = LibStub:NewLibrary(MAJOR, MINOR)

if not Prism then return end

-- Glocals.
local error,tonumber = error,tonumber
local abs,max,min = math.abs, math.max, math.min
local format = string.format

--..--..--..--..--..--..--..--..--..--..--..--..--..--..--..--..--..--
-- :HexAngleGradient(minColor, maxColor, modifier)
-- 
-- - minColor - table or string
--              if table, format is expected to be {r = i, g = i, b = i}
--                where i is a real number and 0<=i<=1
--              if string, a six-digit hexadecimal representation is expected
-- - maxColor - table or string
--              if table, format is expected to be {r = i, g = i, b = i}
--                where i is a real number and 0<=i<=1
--              if string, a six-digit hexadecimal representation is expected
-- - modifier - the modifier to apply, element of R, [0,1]

--- Get the angle gradient between two colors.
-- @paramsig minColor, maxColor, modifier
-- @param minColor The color found at your starting point.
-- @param maxColor The color found at your ending point.
-- @param modifier Percentage describing how far the point the desired color is from the two end points.
-- @usage
-- Call the minColor and maxColor arguments with either a table containing rgb values, formatted as {r = v, g = v, b = v} where c describes the color and {c ∈ ℝ: 0 ≤ c ≤ 1}, or as a string containing a hexadecimal representation of the rgb values, formatted as rrggbb. The modifier is expected to also adhere to the same range, but will default to 0 if m < 0 or 1 if m > 1.
--
-- @return Hexadecimal string, [00,ff][00,ff][00,ff]
-- @return The r value, where {r ∈ ℝ: 0 ≤ r ≤ 1}
-- @return The g value, where {g ∈ ℝ: 0 ≤ g ≤ 1}
-- @return The b value, where {b ∈ ℝ: 0 ≤ b ≤ 1}

function Prism:GetAngleGradient(minColor, maxColor, modifier)
   local msg = nil
   local min,max = {}, {}
   local r,g,b,h,s,v

   if not minColor or not maxColor or not modifier then
      error("Usage: Prism:GetAngleGradient(minColor, maxColor, modifier)", 2)
   elseif type(modifier) ~= "number" then -- or modifier < 0 or modifier > 1 then
      msg = "modifier expected to be a number"
   else
      for _,v in ipairs({minColor, maxColor}) do
	 if type(v) == "table" and (not v.r or v.r < 0 or v.r > 1 or not v.g or v.g < 0 or v.g > 1 or not v.b or v.b < 0 or v.b > 1) then
	    msg = "table format expected to be {r = 0 <= v <= 1, g = 0 <= v <= 1, b = 0 <= v <= 1}"
	    break

	 elseif type(v) == "string" and not string.match(v, '^%x+$') and #string ~= 6 then
	    msg = "string format expected to be 'rrggbb', where rrggbb represents a hexadecimal representation of the color"
	    break

 	 elseif type(v) ~= "table" and type(v) ~= "string" then
	    msg = format("%s expected to be a string or table, not '%s'", v == 1 and "minColor" or "maxColor", type(minColor))
	    break
	 end
      end
   end

   -- better to use this for modifier numbers outside the range, actually..
   if modifier < 0 then modifier = 0 elseif modifier > 1 then modifier = 1 end

   if msg then error(("Usage: Prism:GetAngleGradient(minColor, maxColor, modifier): %s").format(msg), 2) end

   if type(minColor) == "table" then
      min = minColor
   else
      min = {
	 r = tonumber("0x" .. string.sub(minColor, 1, 2)) / 255,
	 g = tonumber("0x" .. string.sub(minColor, 3, 4)) / 255,
	 b = tonumber("0x" .. string.sub(minColor, 5, 6)) / 255,
      }
   end

   if type(maxColor) == "table" then
      max = maxColor
   else
      max = {
	 r = tonumber("0x" .. string.sub(maxColor, 1, 2)) / 255,
	 g = tonumber("0x" .. string.sub(maxColor, 3, 4)) / 255,
	 b = tonumber("0x" .. string.sub(maxColor, 5, 6)) / 255,
      }
   end

   min.h,min.s,min.v = self:RGBtoHSV(min.r, min.g, min.b)
   max.h,max.s,max.v = self:RGBtoHSV(max.r, max.g, max.b)
   h,s,v = min.h + ((max.h - min.h)*modifier)%360, min.s + (max.s - min.s)*modifier, min.v + (max.v - min.v)*modifier
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
-- @paramsig r, g, b
-- @param r The red color value, {r ∈ ℝ: 0 ≤ r ≤ 1}
-- @param g The green color value, {g ∈ ℝ: 0 ≤ g ≤ 1}
-- @param b The blue color value, {b ∈ ℝ: 0 ≤ b ≤ 1}
-- @usage
-- Returns the HSV values corresponding to the input RGB color.
--
-- @return The h value, where {h ∈ ℝ: 0 ≤ h ≤ 360}
-- @return The s value, where {s ∈ ℝ: 0 ≤ s ≤ 1}
-- @return The v value, where {v ∈ ℝ: 0 ≤ v ≤ 1}

function Prism:RGBtoHSV(r, g, b)
   local min,max = min(r,g,b),max(r,g,b)
   local h,s,v = 0,0,max-min

   if max == r then h = ((g-b)/v)%6
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
-- @paramsig h, s, v
-- @param h The hue, {h ∈ ℝ: 0 ≤ h ≤ 360}
-- @param s The saturation, {s ∈ ℝ: 0 ≤ s ≤ 1}
-- @param v The brightness value, {v ∈ ℝ: 0 ≤ v ≤ 1}
-- @usage
-- Returns the RGB values corresponding to the input HSV color.
--
-- @return The r value, where {r ∈ ℝ: 0 ≤ r ≤ 1}
-- @return The g value, where {g ∈ ℝ: 0 ≤ g ≤ 1}
-- @return The b value, where {b ∈ ℝ: 0 ≤ b ≤ 1}

function Prism:HSVtoRGB(h, s, v)
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
