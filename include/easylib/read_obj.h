/*!
  * \headerfile read_obj.h ""
  * \brief 
  * \author Hao Peng
  * \date 2019-10-14 
 */ 
#pragma once
#include<algorithm>
#include <fstream>
#include <sstream>
#include <iterator>
#include <iostream>
#include<Eigen/core>
#include "path_parser.h"
#include "read_mtl.h"
namespace elib {

	template<typename Scalar ,typename Index>
	bool readOBJ(
		const std::string& filename,
		std::vector<std::vector<Scalar>>&vertices,
		std::vector<std::vector<Scalar>>&texture_coordinats,
		std::vector<std::vector<Scalar>>&normals,
		std::vector<std::vector<Scalar>>&colcors,
		std::vector<std::vector<Index>>&facets,
		std::vector<std::vector<Index>>&texture_indices,
		std::vector<std::vector<Index>>& normal_indices);

	template<typename DerivedPoint,typename DerivedIndex>
	bool readOBJ(const std::string&filename,
		Eigen::PlainObjectBase<DerivedPoint>&vertices,
		Eigen::PlainObjectBase<DerivedPoint>&texture_coordinats,
		Eigen::PlainObjectBase<DerivedPoint>&normals,
		Eigen::PlainObjectBase<DerivedPoint>&colors,
		Eigen::PlainObjectBase<DerivedIndex>&facets,
		Eigen::PlainObjectBase<DerivedIndex>&texture_indices,
		Eigen::PlainObjectBase<DerivedIndex>& normal_indices);

	template<typename DerivedPoint, typename DerivedIndex>
	bool readOBJ(const std::string&filename,
		Eigen::PlainObjectBase<DerivedPoint>&vertices,
		Eigen::PlainObjectBase<DerivedIndex>&facets,
		Eigen::PlainObjectBase<DerivedPoint>&colors);

	template<typename DerivedPoint, typename DerivedIndex>
	bool readOBJ(const std::string&filename,
		Eigen::PlainObjectBase<DerivedPoint>&vertices,
		Eigen::PlainObjectBase<DerivedIndex>&facets);


	template<typename Scalar, typename Index>
	bool readOBJ(const std::string & filename, std::vector<std::vector<Scalar>>& vertices, std::vector<std::vector<Scalar>>& texture_coordinats, std::vector<std::vector<Scalar>>& normals, std::vector<std::vector<Scalar>>& colors, std::vector<std::vector<Index>>& facets, std::vector<std::vector<Index>>& texture_indices, std::vector<std::vector<Index>>& normal_indices)
	{

		std::string prefix, name, suffix;
		elib::pathParser(filename, prefix, name, suffix);

		FILE * obj = fopen(filename.c_str(), "r");
		if (obj == NULL) {
			fprintf(stderr, "%s could not be opened...\n",
				filename.c_str());
			return false;
		}
		//clear outputs befor read files;
		vertices.clear();
		texture_coordinats.clear();
		normals.clear();
		colors.clear();
		facets.clear();
		texture_indices.clear();
		normal_indices.clear();


		//define flags
		bool FOUND_MTL = false;
		bool FOUND_COLOR = false;
		bool FACET_COLOR = true;
		//color
		std::vector<elib::MaterialLibrary<Scalar>> mtl_group;
		std::vector <Scalar> color = { 1.,1.,1. };

		int linenum = 0;
		char line[2048];
		
		while (fgets(line, 2048, obj) != NULL) {

			++linenum;

			char type[2048];
			if (sscanf(line, "%s", type) == 1) {
				char *line_rest = &line[strlen(type)];
				std::string type_(type);

				if (type_ == "mtllib") {
					char mtl_file[2048];
					sscanf(line_rest, "%s", mtl_file);
					FOUND_MTL = readMTL(prefix+"/"+std::string(mtl_file), mtl_group);
					continue;
				}

				if (type_ == "usemtl") {
					char mtl_name[2048];
					sscanf(line_rest, "%s", mtl_name);
					if (FOUND_MTL) {
						auto it = std::find(mtl_group.begin(), mtl_group.end(), mtl_name);
						if (it != mtl_group.end()) {
							color.swap(std::vector<Scalar>{it->Kd[0], it->Kd[1], it->Kd[2]});
							FOUND_COLOR = true;
						}
						
					}
					continue;
				}

				if (type_ == "v") {
					double x, y, z;
					int count = sscanf(line_rest, "%lf %lf %lf\n", &x, &y, &z);
					if (FOUND_COLOR) FACET_COLOR = false;

					if (count != 3) {
						fprintf(stderr, "readOBJ() vertex on line %d should have at least 3 coordinates", linenum);
						fclose(obj);
						return false;
					}else{
						vertices.push_back({ x, y, z });
						if (!FACET_COLOR) colors.push_back(color);
					}

					continue;
				}

				if (type_ == "vt") {
					double u, v, w;
					int count = sscanf(line_rest, "%lf %lf %lf\n", &u, &v, &w);
					
					if (count != 3) {
						fprintf(stderr, "readOBJ() texture coordinats on line %d should have at least 3 coordinates", linenum);
						fclose(obj);
						return false;
					}
					else {
						vertices.push_back({ u, v, w });
					}
					continue;
				}

				if (type_ == "vn") {
					double nx, ny, nz;
					int count = sscanf(line_rest, "%lf %lf %lf\n", &nx, &ny, &nz);

					if (count != 3) {
						fprintf(stderr, "readOBJ() vertex normal on line %d should have at least 3 coordinates", linenum);
						fclose(obj);
						return false;
					}
					else {
						vertices.push_back({ nx,ny,nz });
					}
					continue;
				}

				if (type_ == "f") {
					const auto &shift = [&vertices](const int i)->int {return i < 0 ? i + vertices.size() : i - 1; };
					const auto &shift_t = [&texture_coordinats](const int it)->int {return it < 0 ? it + texture_coordinats.size() : it - 1; };
					const auto &shift_n = [&normals](const int in)->int {return in < 0 ? in + normals.size() : in - 1; };

					std::vector<Index> f, ftc, fn;

					// Read each "word" after type
					char word[2048];
					int offset;
					while (sscanf(line_rest, "%s%n", word, &offset) == 1)
					{
						// adjust offset
						line_rest += offset;
						// Process word
						long int i, it, in;
						if (sscanf(word, "%ld/%ld/%ld", &i, &it, &in) == 3)
						{
							f.push_back(shift(i));
							ftc.push_back(shift_t(it));
							fn.push_back(shift_n(in));
						}
						else if (sscanf(word, "%ld/%ld", &i, &it) == 2)
						{
							f.push_back(shift(i));
							ftc.push_back(shift_t(it));
						}
						else if (sscanf(word, "%ld//%ld", &i, &in) == 2)
						{
							f.push_back(shift(i));
							fn.push_back(shift_n(in));
						}
						else if (sscanf(word, "%ld", &i) == 1)
						{
							f.push_back(shift(i));
						}
						else
						{
							fprintf(stderr,
								"readOBJ() face on line %d has invalid element format\n",
								linenum);
							fclose(obj);
							return false;
						}
					}

					if (
						(f.size() > 0 && fn.size() == 0 && ftc.size() == 0) ||
						(f.size() > 0 && fn.size() == f.size() && ftc.size() == 0) ||
						(f.size() > 0 && fn.size() == 0 && ftc.size() == f.size()) ||
						(f.size() > 0 && fn.size() == f.size() && ftc.size() == f.size()))
					{
						// No matter what add each type to lists so that lists are the
						// correct lengths
						facets.push_back(f);
						texture_indices.push_back(ftc);
						normal_indices.push_back(fn);

						if (FACET_COLOR) colors.push_back(color);

					}
					else
					{
						fprintf(stderr,
							"readOBJ() face on line %d has invalid format\n", linenum);
						fclose(obj);
						return false;
					}
					continue;
				}

				if (strlen(type) >= 1 && (type[0] == '#' || type[0] == 'g' || type[0] == 's')) {
					continue;
				}
			}//end of if
		}//end of while

		fclose(obj);
		return true;
	}

	template<typename DerivedPoint, typename DerivedIndex>
	bool readOBJ(const std::string & filename, Eigen::PlainObjectBase<DerivedPoint>& vertices, Eigen::PlainObjectBase<DerivedPoint>& texture_coordinats, Eigen::PlainObjectBase<DerivedPoint>& normals, Eigen::PlainObjectBase<DerivedPoint>& colors, Eigen::PlainObjectBase<DerivedIndex>& facets, Eigen::PlainObjectBase<DerivedIndex>& texture_indices, Eigen::PlainObjectBase<DerivedIndex>& normal_indices)
	{
		typedef typename DerivedPoint::Scalar Scalar;
		typedef typename DerivedIndex::Scalar Index;

		const auto &list_to_matrix_scalar = [](const std::vector<std::vector<Scalar>>&in, Eigen::PlainObjectBase<DerivedPoint>&out) {

			int r = in.size();
			int c =r>0? in.front().size():0;
			if (c == 0) r == 0;

			out.resize(r, c);

			for (int i = 0; i < r; i++) {
				for (int j = 0; j < c; j++) {
					out(i, j) = in[i][j];
				}
			}

		};

		const auto &list_to_matrix_index = [](const std::vector<std::vector<Index>>&in, Eigen::PlainObjectBase<DerivedIndex>&out) {

			int r = in.size();
			int c = r > 0 ? in.front().size() : 0;
			if (c == 0) r == 0;
			out.resize(r, c);

			for (int i = 0; i < r; i++) {
				for (int j = 0; j < c; j++) {
					out(i, j) = in[i][j];
				}
			}

		};

		std::vector<std::vector<Scalar>> V, TC, TN, C;
		std::vector<std::vector<Index>> F, FT, FN;

		if (!readOBJ(filename, V, TC, TN, C, F, FT, FN)) {
			return false;
		}
		

		list_to_matrix_scalar(V, vertices);
		list_to_matrix_scalar(TC, texture_coordinats);
		list_to_matrix_scalar(TN, normals);
		list_to_matrix_scalar(C, colors);
		list_to_matrix_index(F, facets);
		list_to_matrix_index(FT, texture_indices);
		list_to_matrix_index(FN, normal_indices);

		return true;
	}

	template<typename DerivedPoint, typename DerivedIndex>
	bool readOBJ(const std::string & filename, Eigen::PlainObjectBase<DerivedPoint>& vertices, Eigen::PlainObjectBase<DerivedIndex>&facets, Eigen::PlainObjectBase<DerivedPoint>& colors)
	{
		Eigen::PlainObjectBase<DerivedPoint>  TC, TN;
		Eigen::PlainObjectBase<DerivedIndex> FT, FN;
		return readOBJ(filename,vertices, TC, TN, colors, facets, FT, FN);
	}

	template<typename DerivedPoint, typename DerivedIndex>
	bool readOBJ(const std::string & filename, Eigen::PlainObjectBase<DerivedPoint>& vertices, Eigen::PlainObjectBase<DerivedIndex>& facets)
	{
		Eigen::PlainObjectBase<DerivedPoint>  TC, TN, C;
		Eigen::PlainObjectBase<DerivedIndex> FT, FN;
		return readOBJ(filename,vertices, TC, TN, C, facets, FT, FN);
	}

} 