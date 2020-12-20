
#include <boost/log/trivial.hpp>
#include <boost/property_tree/ptree.hpp>
#include <boost/property_tree/json_parser.hpp>

namespace pt = boost::property_tree;

int main() {
	pt::ptree ptree;
	ptree.add("debug.test", 45);
	ptree.add("log", "String");
	std::ostringstream oss;
	pt::json_parser::write_json(oss, ptree);
	BOOST_LOG_TRIVIAL(severity_level::debug) << oss.str();
	return 1;
}
