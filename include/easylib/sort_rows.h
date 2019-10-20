/*!
  * \headerfile sort_rows.h ""
  * \brief Sort Eigen matrix by rows.
  * \author Hao Peng
  * \date 2019-10-20 
 */ 
#pragma once
#include<algorithm>
#include<Eigen/core>

namespace elib {

	/*!
	  *  \fn template<typename DerivedVector,typename DerivedIndex>
		void sortRows(const Eigen::MatrixBase<DerivedVector> &input, const bool ascending, Eigen::PlainObjectBase<DerivedVector> &output, Eigen::PlainObjectBase<DerivedIndex> &indices);
	  *  \brief  Sort Eigen matrix by rows
	  *  \param[in] input   m by n matrix will be sorted by rows
	  *  \param[in] ascending   sort ascending (true) or descending (false)
	  *  \param[out] output   m by n matrix sorted by rows
	  *  \param[out] indices   m list of indices so that output=input(indices,:)
	  *  \return void
	 */
	template<typename DerivedVector,typename DerivedIndex>
	void sortRows(const Eigen::MatrixBase<DerivedVector> &input, const bool ascending, Eigen::PlainObjectBase<DerivedVector> &output, Eigen::PlainObjectBase<DerivedIndex> &indices);
	template<typename DerivedVector, typename DerivedIndex>
	void sortRows(const Eigen::MatrixBase<DerivedVector> &input, const bool ascending, Eigen::PlainObjectBase<DerivedVector> &output);
	template<typename DerivedVector, typename DerivedIndex>
	void sortRows(const Eigen::MatrixBase<DerivedVector> &input, Eigen::PlainObjectBase<DerivedVector> &output);
	template<typename DerivedVector, typename DerivedIndex>
	void sortRows(const Eigen::MatrixBase<DerivedVector> &input,Eigen::PlainObjectBase<DerivedVector> &output, Eigen::PlainObjectBase<DerivedIndex> &indices);
	

	template<typename DerivedVector, typename DerivedIndex>
	void sortRows(const Eigen::MatrixBase<DerivedVector>& input, const bool ascending, Eigen::PlainObjectBase<DerivedVector>&output, Eigen::PlainObjectBase<DerivedIndex>& indices)
	{

		const int nr = input.rows();
		const int nc = input.cols();

		output.resize(nr, nc);
		indices.setLinSpaced(nr, 0, static_cast<DerivedIndex::Scalar>(nr - 1));

		if (ascending) {
			auto less = [&input, nc](int i, int j) {
				for (int c = 0; c < nc; ++c) {
					if (input.coeff(i, c) < input.coeff(j, c)) return true;
					if(input.coeff(i, c) > input.coeff(j, c)) return false;
				}
				return false;
			};

			std::sort(indices.data(), indices.data() + indices.rows(),less);
		}
		else {
			auto greater= [&input, nc](int i, int j) {
				for (int c = 0; c < nc; ++c) {
					if (input.coeff(i, c) < input.coeff(j, c)) return false;
					if (input.coeff(i, c) > input.coeff(j, c)) return true;
				}
				return false;
			};

			std::sort(indices.data(), indices.data() + indices.rows(), less);
		}

		for (int r = 0; r < nr; ++r) 
			for (int c = 0; c < nc; ++c) 
				output.coeff(r, c) = input(indices(r), c);
	}

	template<typename DerivedVector, typename DerivedIndex>
	void sortRows(const Eigen::MatrixBase<DerivedVector>& input, const bool ascending, Eigen::PlainObjectBase<DerivedVector>& output)
	{
		Eigen::Matrix<int, DerivedIndex::RowsAtCompileTime, 1> indices;
		elib::sortRows(input,ascending,output,indices)
	}

	template<typename DerivedVector, typename DerivedIndex>
	void sortRows(const Eigen::MatrixBase<DerivedVector>& input, Eigen::PlainObjectBase<DerivedVector>& output)
	{
		Eigen::Matrix<int, DerivedIndex::RowsAtCompileTime, 1> indices;
		elib::sortRows(input, true, output, indices)
	}

	template<typename DerivedVector, typename DerivedIndex>
	void sortRows(const Eigen::MatrixBase<DerivedVector>& input, Eigen::PlainObjectBase<DerivedVector>& output, Eigen::PlainObjectBase<DerivedIndex>& indices)
	{
		elib::sortRows(input, true, output, indices)
	}

}