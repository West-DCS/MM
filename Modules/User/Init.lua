do
    local Init = {
        'src'
    }

    if CONFIG.Dev then
        table.insert(Init, 'mm-dev')
    end

    return Init
end