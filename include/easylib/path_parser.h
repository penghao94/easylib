/*!
  * \headerfile path_parser.h ""
  * \brief parse a path to <perfix>/<name>.<suffix>
  * \author Hao Peng
  * \date 2019-10-16 
 */ 
#pragma once
#include<string>
#include<regex>
#include<vector>
namespace elib{

	bool pathParser(const std::string &file, std::string& prefix, std::string& name,std::string&suffix);


	bool elib::pathParser(const std::string & file, std::string & prefix, std::string & name, std::string& suffix)
	{
		std::vector<std::string> path;
		std::smatch result;

		std::regex pattern("([^<>/\\\\\|:""\\*\\?\\.]+)");

		std::string::const_iterator iterStart = file.begin();
		std::string::const_iterator iterEnd = file.end();

		while (std::regex_search(iterStart, iterEnd, result, pattern))
		{
			path.push_back(result[0]);
			iterStart = result[0].second;
		}
		prefix = path[0] + ":";

		for (int i = 1; i < path.size() - 2; i++) prefix += ("/" + path[i]);
		name = path[path.size()-2];
		suffix = path.back();
		return true;
	}
}
