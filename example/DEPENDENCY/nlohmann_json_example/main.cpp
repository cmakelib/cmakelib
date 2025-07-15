#include <nlohmann/json.hpp>
#include <iostream>
#include <string>

using json = nlohmann::json;

int main() {
    json data;
    data["name"] = "CMLIB Example";
    data["version"] = "1.0.0";
    data["features"] = json::array({"dependency tracking", "cmake integration", "caching"});
    data["config"]["debug"] = true;
    data["config"]["cache_enabled"] = true;
    
    std::cout << "Generated JSON:" << std::endl;
    std::cout << data.dump(2) << std::endl;
    
    std::string json_string = R"({
        "library": "nlohmann/json",
        "version": "3.12.0",
        "downloaded_via": "CMLIB_DEPENDENCY"
    })";
    
    json parsed = json::parse(json_string);
    std::cout << "\nParsed JSON:" << std::endl;
    std::cout << "Library: " << parsed["library"] << std::endl;
    std::cout << "Version: " << parsed["version"] << std::endl;
    std::cout << "Downloaded via: " << parsed["downloaded_via"] << std::endl;
    
    return 0;
}
