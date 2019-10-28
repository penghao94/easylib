/*!
  * \headerfile read_csv.h ""
  * \brief Read an Eigen matrix from a .csv file
  * \author Hao Peng
  * \date 2019-10-23 
 */ 
#pragma once
#include<cstdio>
#include<fstream>
#include <string>
#include<regex>

#include<Eigen/core>

namespace elib {
	template<typename Derived>
	bool readCSV(const std::string&filename, const int start_row,const int start_col, const int end_row, const int end_col,  Eigen::PlainObjectBase<Derived>&matrix);

	template<typename Derived>
	bool readCSV(const std::string & filename, Eigen::PlainObjectBase<Derived>& matrix);

	template<typename Derived>
	bool readCSV(const std::string & filename, Eigen::PlainObjectBase<Derived>& matrix)
	{
		
		return readCSV(filename, -1, -1, -1, -1, matrix);
	}
	template<typename Derived>
	bool readCSV(const std::string & filename, const int start_row, const int start_col, const int end_row, const int end_col, Eigen::PlainObjectBase<Derived>& matrix)
	{

		std::ifstream in(filename.data(), std::ios::in);

		if (!in.is_open()) {
			fprintf(stderr, "readCSV() could not open %s!\n", filename.c_str());
		}

		std::vector<std::vector<Derived::Scalar>> matrix_;
		int col = 0;
		
		std::string line;

		while (std::getline(in, line)) {
			if(line.empty()) continue;

			line = std::regex_replace(line, ",", " ");

			std::smatch result;
			std::regex pattern("\\S+");
			std::string::const_iterator iterStart = line.begin();
			std::string::const_iterator iterEnd = line.end();

			std::vector<Derived::Scalar> vec;

			while (std::regex_search(iterStart, iterEnd, pattern, result))
			{
				vec.push_back(static_cast<Derived::Scalar>(atof(result[0].str().c_str())));
				iterStart = result[0].second;
			}
			
			matrix_.push_back(vec);

			col = col > vec.size() ? col : vec.size();
		
		}
		const int row = matrix_.rows();

		int row_start_, row_end_, col_start_, col_end_;

		if (start_row < 0) {
			row_start_ = 0;
		}	
		else if (start_row >= end_row || start_row_ >= row) {
			fprintf(stderr, "Out of bound of matrix in row!");
			return false;
		}
		else{
			row_start_ = start_row;
		}


		if (start_col < 0) {
			col_start_ = 0;
		}
		else if (start_col >= end_col || start_col >= col) {
			fprintf(stderr, "Out of bound of matrix in col!");
			return false;
		}
		else {
			col_start_ = start_col;
		}

		if (end_row < 0) {
			row_end_ = row;
		}
		else if (end_row > row) {
			fprintf(stderr, "Out of bound of matrix in row!");
			return false;
		}
		else {
			row_end_ = end_row;
		}

		if (end_col < 0) {
			col_end_ = col;
		}
		else if (end_col >= col) {
			fprintf(stderr, "Out of bound of matrix in col!");
			return false;
		}
		else {
			col_end_ = end_col;
		}


		matrix.resize(row_end_ - row_start_, col_end_ - col_start_);

		for (int r = row_start_; r < row_end_; ++r) {
			for (int c = col_start_; c < col_end_; ++c) {
				matrix(r, c) = matrix_[r][c];
			}
		}

		return true;
	}
}