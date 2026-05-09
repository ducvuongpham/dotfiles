-- Shared popup registry. Lets any popup-owning widget close every other
-- widget's popup when it opens its own (so only one popup is visible at a time).
local M = { closers = {} }

function M.register(name, close_fn)
  M.closers[name] = close_fn
end

function M.close_all_except(name)
  for n, fn in pairs(M.closers) do
    if n ~= name then fn() end
  end
end

function M.close_all()
  for _, fn in pairs(M.closers) do fn() end
end

-- Apps that, when becoming frontmost, should NOT trigger popup close — the
-- user just clicked one of our "Open … Settings" links and we want them to
-- come back to the popup state.
local STAY_OPEN_FOR = {
  ["System Settings"] = true,
  ["System Preferences"] = true,
}

function M.is_stay_open_app(name)
  return STAY_OPEN_FOR[name] == true
end

return M
