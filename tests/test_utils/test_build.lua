local test_build = {}

function test_build:build(argv)
    os.exec("xmake f -c -D -y")
    os.exec("xmake")
end

function main()
    return test_build
end
