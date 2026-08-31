-- GC-guarded loadScript wrapper.
--
-- Bootstrapped with a bare loadScript by whoever wants it -- it is the one
-- module that cannot load itself.
--
-- Collecting before each load frees the previous compile's parser scratch. The
-- firmware runs no GC between loadScript calls, so on a card whose .luac are
-- missing the compile peaks stack, which is what the 128x64 heap runs out of
-- first. Every load site in this tree already paired loadScript with a
-- collectgarbage(); this puts the pair in one place and makes the failure name
-- the file rather than saying "assertion failed!".

--- Load a script and run it, passing any further arguments through.
--- @param path string  path relative to /SCRIPTS/BF, or absolute
--- @return any  whatever the script returns
local function loader(path, ...)
    collectgarbage()
    local chunk = loadScript(path)
    if chunk == nil then
        error(path)
    end
    return chunk(...)
end

return loader
