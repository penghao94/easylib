/*!
  * \headerfile write_obj.h ""
  * \brief write a surface to an obj file
  * \author Hao Peng
  * \date 2019-10-16 
 */ 
#pragma once
#include <string>
#include <fstream>
#include <regex>
#include <Eigen/core>
#include "path_parser.h"
namespace elib {
	/*!
	  *  \fn template<typename DerivedPoint,typename DerivedIndex>
		bool writeOBJ(const std::string &filename, const Eigen::MatrixBase<DerivedPoint>&vertices, Eigen::MatrixBase<DerivedIndex>&facets);
	  *  \brief write a surface to an obj file
	  *  \param[in] filename   a path to write obj file
	  *  \param[in] vertices   #V by 3 vertices of the surface
	  *  \param[in] facets   #N by 3 indices of the surfaces
	  *  \return bool
	 */
	template<typename DerivedPoint,typename DerivedIndex>
	bool writeOBJ(const std::string &filename, const Eigen::MatrixBase<DerivedPoint>&vertices, const Eigen::MatrixBase<DerivedIndex>&facets);

	/*!
	  *  \fn template<typename DerivedPoint, typename DerivedIndex>
	bool writeOBJ(const std::string &filename, const Eigen::MatrixBase<DerivedPoint>&vertices, Eigen::MatrixBase<DerivedIndex>&facets, const Eigen::MatrixBase<DerivedPoint>&colors,bool FACECOLOR=true);
	  *  \brief write a surface to an obj file
	  *  \param[in] filename   a path to write obj file
	  *  \param[in] vertices   #V by 3 vertices of the surface
	  *  \param[in] facets   #N by 3 indices of the surfaces
	  *  \param[in] colors   #V by 3 or #N by 3 colors of surface
	  *  \param[in] FACECOLOR    face color or vertex color, default face color true
	  *  \return bool
	 */
	template<typename DerivedPoint, typename DerivedIndex>
	bool writeOBJ(const std::string &filename, const Eigen::MatrixBase<DerivedPoint>&vertices, Eigen::MatrixBase<DerivedIndex>&facets, const Eigen::MatrixBase<DerivedPoint>&colors,bool FACECOLOR=true);





	template<typename DerivedPoint, typename DerivedIndex>
	bool writeOBJ(const std::string & filename, const Eigen::MatrixBase<DerivedPoint>& vertices, const Eigen::MatrixBase<DerivedIndex>& facets)
	{
		assert(vertices.rows() != 3 && "V should have 3 columns");
		std::ofstream file(filename);
		if (!file.is_open()) {
			fprintf(stderr, "writeOBJ() could not open %s\n", filename.c_str());
			return false;
		}

		file << vertices.format(Eigen::IOFormat(Eigen::FullPrecision, Eigen::DontAlignCols, " ", "\n", "v ", "", "", "\n")) <<
			(facets.array() + 1).matrix().format(Eigen::IOFormat(Eigen::FullPrecision, Eigen::DontAlignCols, " ", "\n", "f ", "", "", "\n"));

		return true;
	}

	

	template<typename DerivedPoint, typename DerivedIndex>
	bool writeOBJ(const std::string & filename, const Eigen::MatrixBase<DerivedPoint>& vertices, Eigen::MatrixBase<DerivedIndex>& facets, const Eigen::MatrixBase<DerivedPoint>& colors,bool FACECOLOR)
	{
		assert(vertices.rows() != 3 && "V should have 3 columns");


		std::string prefix, name, suffix;
		elib::pathParser(filename, prefix, name, suffix);

		
		std::string mtlname = prefix + name + ".mtl";
		std::ofstream mtl(mtlname);
		if (!mtl.is_open()) {
			fprintf(stderr, "writeOBJ() could not open %s\n", mtlname.c_str());
			return false;
		}
		
		obj << "# Surface generated by easylib.\n" << "mtllib " << name << ".mtl\n" << std::endl;
		mtl << "# " + name + ".mtl generated by easylib\n";

		for (int i = 0; i < colors.rows(); i++) {
			mtl << "\nnewmtl object_" << std::to_string(i) << "\nKd" << std::to_string(colors(i, 0)) << " " << std::to_string(colors(i, 1)) << " " << std::to_string(colors(i, 2)) << "\n";
		}

		mtl.close();


		std::ofstream obj(filename);
		if (!obj.is_open()) {
			fprintf(stderr, "writeOBJ() could not open %s\n", filename.c_str());
			return false;
		}

		if (!FACECOLOR) {

			if (vertices.rows() != colors.rows()) {
				fprintf(stderr, "Colors should have the same rows with vertices!!");
				return false;
			}
			for (int i = 0; i < vertices.rows(); i++) {
				obj << "usemtl object_" << std::to_string(i) << "\n";
				obj << vertices.row(i).format(Eigen::IOFormat(Eigen::FullPrecision, Eigen::DontAlignCols, " ", "\n", "v ", "", "", ""));
			}

			obj << (facets.array() + 1).matrix().format(Eigen::IOFormat(Eigen::FullPrecision, Eigen::DontAlignCols, " ", "\n", "f ", "", "\n", "\n"));
		}
		else {
			if (facets.rows() != colors.rows()) {
				fprintf(stderr, "Colors should have the same rows with facets!!");
				return false;
			}
			obj << vertices.format(Eigen::IOFormat(Eigen::FullPrecision, Eigen::DontAlignCols, " ", "\n", "v ", "", "", "\n"));
			auto facets_ = (facets.array() + 1).matrix();
			for (int i = 0; i < facets_.rows(); i++) {
				obj << "usemtl object_" << std::to_string(i) << "\n";
				obj << facets_.row(i).format(Eigen::IOFormat(Eigen::FullPrecision, Eigen::DontAlignCols, " ", "\n", "f ", "", "", ""));
			}
		}
		obj.close();
		return true;
	}

}
