-- This module is meant to serve as a base for websites using WordPress.
-- Dependent modules should be defined as generic for it to work properly.

function GetInfo()

    if(API_VERSION < 20240919) then
        return
    end

    if(not module.IsGeneric) then
        return
    end

    -- If no WordPress theme has been set by a descendant module, do nothing.

    if(type(WORDPRESS_THEME) ~= 'string') then
        Fail(Error.DomainNotSupported)
    end

    -- Get the name of the current WordPress theme.

    local wordPressTheme = dom.SelectValue('//link[contains(@href,"/wp-content/themes/")]'):regex('wp-content\\/themes\\/([^\\/"\']+)', 1)

    local isGenericMatch = WORDPRESS_THEME:lower() == wordPressTheme:lower()

    if(not isGenericMatch) then
        Fail(Error.DomainNotSupported)
    end

    -- Get generic information; the dependent module can change it or add more later.

    info.Title = dom.SelectValue('//h1')

end
