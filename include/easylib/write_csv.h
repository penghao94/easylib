/*!
  * \headerfile write_csv.h ""
  * \brief Write Eigen matrix into a .csv file.
  * \author Hao Peng
  * \date 2019-10-23 
 */ 
#pragma once
#include<cstdio>
#include<fstream>
#include<Eigen/core>
namespace elib {
	/*!
	  *  \fn template<typename Derived>
		bool writeCSV(const std::string &filename, const Eigen::MatrixBase<Derived>&matrix, const bool append=false);
	  *  \brief  Write Eigen matrix into a .csv file.
	  *  \param[in] filename   path to .csv file
	  *  \param[in] matrix   #m by n Eigen matrix
	  *  \param[in] append   appending or overwrite, default overwrite
	  *  \return bool
	 */
	template<typename Derived>
	bool writeCSV(const std::string &filename, const Eigen::MatrixBase<Derived>&matrix, const bool append=false);

	template<typename Derived>
	bool writeCSV(const std::string & filename, const Eigen::MatrixBase<Derived>& matrix, const bool append)
	{
		std::ofstream out;
		if (append)
			out.open(filename, std::ios::app);
		else
			out.open(filename);

		if (!out.is_open()) {
			fprintf(stderr, "writeCSV( could not open %s!\n)", filename.c_str());
			return false;
		}

		out << matrix.format(Eigen::IOFormat(Eigen::FullPrecision, Eigen::DontAlignCols, ",", "\n", "", "", "", ""));
		out.close();
		return true;
	}
}
