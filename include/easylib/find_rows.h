/*!
  * \headerfile find_rows.h ""
  * \brief A function to find Eigen matrix by rows
  * \author Hao Peng
  * \date 2019-10-22 
 */ 
#pragma once
#include <algorithm>
#include<vector>
#include <Eigen/core>
namespace elib {

	/*!
	  *  \fn template<typename Derived,typename DerivedRow,typename DerivedIndex>
	 bool findRows(const Eigen::MatrixBase<Derived>&matrix, const Eigen::MatrixBase<DerivedRow> &row, const double tolarance,Eigen::PlainObjectBase<DerivedIndex>& indices);
	  *  \brief   function to find Eigen matrix by rows
	  *  \param[in] matrix   #m by #n Eigen matrix
	  *  \param[in] row   #n by 1 Eigen vector
	  *  \param[in] tolarance   A tolarance to determine if equal or not
	  *  \param[out] indices   indices of equal item
	  *  \return bool
	 */
	template<typename Derived, typename DerivedRow, typename DerivedIndex>
	bool findRows(const Eigen::MatrixBase<Derived>&matrix, const Eigen::MatrixBase<DerivedRow> &row, const double tolarance, Eigen::PlainObjectBase<DerivedIndex>& indices);

	template<typename Derived, typename DerivedRow, typename DerivedIndex>
	bool findRows(const Eigen::MatrixBase<Derived>&matrix, const Eigen::MatrixBase<DerivedRow> &row, Eigen::PlainObjectBase<DerivedIndex>& indices);

	template<typename Derived, typename DerivedRow>
	bool findRows(const Eigen::MatrixBase<Derived>&matrix, const Eigen::MatrixBase<DerivedRow> &row, const double tolarance, int &indices);

	template<typename Derived, typename DerivedRow>
	bool findRows(const Eigen::MatrixBase<Derived>&matrix, const Eigen::MatrixBase<DerivedRow> &row, int& indices);

	template<typename Derived, typename DerivedRow, typename DerivedIndex>
	bool findRows(const Eigen::MatrixBase<Derived>&matrix, const Eigen::MatrixBase<DerivedRow> &row, const double tolarance, Eigen::PlainObjectBase<DerivedIndex>& indices)
	{

		typedef Eigen::Matrix < DerivedRow::Scalar, Eigen::Dynamic, 1 > Vector;
		std::vector<int> index;
		const auto row_equal = [&tolarance](Vector &a, Vector&b)->bool {
			if (tolarance == 0) {
				for (int i = 0; i < a.rows(); i++) {
					if (a(i) != b(i)) return false;
				}
			}
			else {
				for (int i = 0; i < a.rows(); i++) {
					if (abs(static_cast<double>(a(i) - b(i))) > abs(tolarance)) return false;
				}
			}
			return true;
		};

		for (int i = 0; i < matrix.rows(); ++i) {
				Vector m = matrix.row(i).transpose().cast< DerivedRow::Scalar>();
				Vector r = row;
				if (row_equal(m, r)) index.push_back(i);
		}

		if (index.empty()) return false;

		indices.resize(index.size());
		for (int i = 0; i < index.size(); ++i) indices(i) = index[i];
		return true;

	}

	template<typename Derived, typename DerivedRow, typename DerivedIndex>
	bool findRows(const Eigen::MatrixBase<Derived>& matrix, const Eigen::MatrixBase<DerivedRow>& row, Eigen::PlainObjectBase<DerivedIndex>& indices)
	{
		Eigen::VectorXi indices_;
		return findRows(matrix, row, 0, indices_);
	}

	template<typename Derived, typename DerivedRow>
	bool findRows(const Eigen::MatrixBase<Derived>& matrix, const Eigen::MatrixBase<DerivedRow>& row, const double tolarance, int &indices)
	{
		Eigen::VectorXi indices_;
		bool found = findRows(matrix, row, tolarance, indices_);
		indices = indices_(0);
		return found;
	}

	template<typename Derived, typename DerivedRow>
	bool findRows(const Eigen::MatrixBase<Derived>& matrix, const Eigen::MatrixBase<DerivedRow>& row, int& indices)
	{
		Eigen::VectorXi indices_;
		bool found = findRows(matrix, row, 0.0, indices_);
		indices = indices_(0);
		return found;
	}


}
