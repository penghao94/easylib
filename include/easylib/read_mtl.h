/*!
  * \headerfile read_mtl.h ""
  * \brief Read material information from MTL files. 
  * \author Hao Peng
  * \date 2019-10-12 
 */ 
#pragma once
#include<vector>
#include<string>
#include<cstdio>
#include "material_library.h"
namespace elib {

	

	template<typename T>
	bool readMTL(const std::string &filename, std::vector<MaterialLibrary<T>>&MaterialGroup);


	template<typename T>
	bool readMTL(const std::string & filename, std::vector<MaterialLibrary<T>>& MaterialGroup)
	{
		FILE * mtl = fopen(filename.c_str(), "r");
		if(NULL ==mtl){
			fprintf(stderr, "%s could not be opened...\n", filename.c_str());
			return false;
		}

		MaterialGroup.clear();

		char line[2048];

		while (fgets(line, 2048, mtl) != NULL) {
			
			char keyword[2048];
			// Read first word containing type
			sscanf(line,"%s",keyword);
			std::string keyword_(keyword);

			if (keyword_ == "newmtl") {
				char mtl_name_[2048];
				sscanf(line, "%s %s", keyword, mtl_name_);
				MaterialLibrary<T> mtl;
				MaterialGroup.push_back(mtl);
				MaterialGroup.back().mtl_name = std::string(mtl_name_);
				continue;
			}

			if (keyword_ == "Ka") {
				T r, g, b;
				sscanf(line, "Ka %lf %lf %lf", &r,&g,&b);
				MaterialGroup.back().Ka = {r,g,b};
				continue;
			}

			if (keyword_ == "Kd") {
				T r, b, g;
				sscanf(line, "Kd %lf %lf %lf", &r, &g, &b);
				MaterialGroup.back().Kd = {r,g,b};
				continue;
			}

			if (keyword_ == "Ks") {
				T r, b, g;
				sscanf(line, "Ks %lf %lf %lf", &r, &g, &b);
				MaterialGroup.back().Ks = {r,g,b};
				continue;
			}

			if (keyword_ == "d") {
				T d_;
				sscanf(line, "d %lf", &d_);
				MaterialGroup.back().d = d_;
				continue;
			}

			if (keyword_ == "Tr") {
				T Tr_;
				sscanf(line, "Tr %lf", &Tr_);
				MaterialGroup.back().Tr = Tr_;
				continue;
			}

			if (keyword_ == "Ns") {
				T Ns_;
				sscanf(line, "Ns %lf", &Ns_);
				MaterialGroup.back().Ns = Ns_;
				continue;
			}

			if (keyword_ == "illum") {
				T illum_;
				sscanf(line, "illum %lf", &illum_);
				MaterialGroup.back().illum = illum_;
				continue;
			}

			if (keyword_ == "map_ka") {
				char map_ka_[2048];
				sscanf(line, "map_ka %s", map_ka_);
				MaterialGroup.back().map_Ka = std::string(map_ka_);
				continue;
			}

		}

		return true;
	}

}
