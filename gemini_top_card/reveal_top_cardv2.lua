--- STEAMODDED HEADER
--- MOD_NAME: Reveal Top Card
--- MOD_ID: reveal_top_card_v2
--- MOD_AUTHOR: [silenceWerks]
--- MOD_DESCRIPTION: Adds a pop up window to deck that reveals the next card that will be drawn from your deck.

-- Capture global variables locally for better performance, readability, and namespace protection
local CONTROLLER = G.CONTROLLER
local HOVER = G.HOVER
local P_CENTERS = G.P_CENTERS
local CARD_W = G.CARD_W
local CARD_H = G.CARD_H

--[[
  This mod patches the CardArea:update() method in the base cardarea.lua file.
  It will add the functionality to display the preview window on the deck, and handle the
  creation and removal of the UIBox.
--]]
do
    local original_update = CardArea.update
    function CardArea:update(dt)
        -- Initialize G.HOVER here, before anything else
        HOVER = HOVER or { deck = false, preview = nil }
        
        -- Early exit if this is not the deck CardArea
        if self ~= G.deck then
            original_update(self, dt)
            return
        end

        original_update(self, dt)

        ----------------------------------------------
        ------------MOD CODE -------------------------

        -- reveals the next card
        -- modify CardArea:update() method to:
        -- check if the mouse is hovering over the deck.
        -- if so, create and show the preview window.
        -- if not, hide or remove the preview window.
        if self == G.deck and G.deck ~= nil then
            -- check to see if the controller is over the deck
            local controllerFocused = CONTROLLER.focused.target == self

            local mouseHovering = self.states.hover.is

            HOVER.deck = controllerFocused or mouseHovering

            -- Create the preview if the mouse is over the deck, and if there is a card to show
            if HOVER.deck and #self.cards >= 1 and HOVER.preview == nil then
                -- Create a copy of the top card
                local top_card = self.cards[#self.cards]:save()
                local preview_card = Card(0,0, CARD_W, CARD_H, P_CENTERS.j_joker, P_CENTERS.c_base)
                preview_card:load(top_card)
                -- Ensure the preview card is facing front
                if preview_card.facing ~= "front" then
                    preview_card:flip()
                end
                HOVER.preview = UIBox{
                     definition = 
                     {n=G.UIT.ROOT, config = {align = 'cm', colour = G.C.BLACK, r=0.1, padding=0.05}, nodes={
                         {n=G.UIT.O, config = {object=preview_card, w=2, h=2.5, scale = 1.0}}
                     }},
                     config = { align = 'cm', offset = {x=0,y=-3}, major = self, parent = self}
                 }
                HOVER.preview.states.collide.can = false
                HOVER.preview.preview_card = preview_card -- Store reference to the copy

            elseif HOVER.preview and not HOVER.deck then
                --remove the preview if the mouse is not hovering.
                -- cleanup copied card.
                if HOVER.preview.preview_card then
                    HOVER.preview.preview_card:remove()
                end
                HOVER.preview:remove()
                HOVER.preview = nil
            end
        end

        ----------------------------------------------
        ------------MOD CODE END----------------------
    end
end

--[[
    This mod patches the card area draw function to display the preview card.
]]
do
    local original_draw = CardArea.draw
    function CardArea:draw()
        -- Initialize G.HOVER here, before accessing G.HOVER.preview
        HOVER = HOVER or { deck = false, preview = nil }

        original_draw(self)
        -- reveal top card from deck
        if HOVER.preview then HOVER.preview:draw() end
    end
end
