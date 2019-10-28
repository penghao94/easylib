/*!
  * \headerfile unique_rows.h ""
  * \brief unique a Eigen matrix by rows
  * \author Hao Peng
  * \date 2019-10-20 
 */ 
#pragma once
#include<algorithm>
#include<vector>
#include<Eigen/core>
#include "sort_rows.h"
namespace elib {
	/*!
	  *  \fn template<typename DerivedVector,typename DerivedIndex>
	void uniqueRows(const Eigen::MatrixBase<DerivedVector>&A,const double tolarance, Eigen::PlainObjectBase<DerivedVector>&C, Eigen::PlainObjectBase<DerivedIndex>& IA, Eigen::PlainObjectBase<DerivedIndex>&IC);
	  *  \brief  Unique an Eigen matrix by rows()
	  *  \param[in] A    m by n matrix are to unique by rows
	  *  \param[in] tolarance   tolarance to be regraded as equal a=b if abs(a-b)<tolarance
	  *  \param[out] C   #C vector of unique rows in A
	  *  \param[out] IA   #C index vector so that C = A(IA,:);
	  *  \param[out] IC   #A index vector so that A = C(IC,:);
	  *  \return void
	 */
	template<typename DerivedVector,typename DerivedIndex>
	void uniqueRows(const Eigen::MatrixBase<DerivedVector>&A,const double tolarance, Eigen::PlainObjectBase<DerivedVector>&C, Eigen::PlainObjectBase<DerivedIndex>& IA, Eigen::PlainObjectBase<DerivedIndex>&IC);

	template<typename DerivedVector, typename DerivedIndex>
	void uniqueRows(const Eigen::MatrixBase<DerivedVector>&A,  Eigen::PlainObjectBase<DerivedVector>&C, Eigen::PlainObjectBase<DerivedIndex>& IA, Eigen::PlainObjectBase<DerivedIndex>&IC);

	template<typename DerivedVector>
	void uniqueRows(const Eigen::MatrixBase<DerivedVector>&A,  Eigen::PlainObjectBase<DerivedVector>&C);

	template<typename DerivedVector>
	void uniqueRows(const Eigen::MatrixBase<DerivedVector>&A , const double tolarance, Eigen::PlainObjectBase<DerivedVector>&C);

	template<typename DerivedVector, typename DerivedIndex>
	void uniqueRows(const Eigen::MatrixBase<DerivedVector>& A, const double tolarance, Eigen::PlainObjectBase<DerivedVector>& C, Eigen::PlainObjectBase<DerivedIndex>& IA, Eigen::PlainObjectBase<DerivedIndex>& IC)
	{
		//Sort A before unique method
		DerivedVector sorted_A;
		DerivedIndex indices_A;
		elib::sortRows(A, sorted_A, indices_A);


		const int nr = sorted_A.rows();
		const int nc = sorted_A.cols();

		std::vector<int> sorted_IA(nr);
		for (int i = 0; i < nr; ++i) sorted_IA[i] = i;

		auto row_equal = [&sorted_A, &nc,&tolarance](const int i, const int j) {
			for (int c = 0; c < nc; ++c) {
				if (tolarance==0) {
					if (sorted_A(i, c) != sorted_A(j, c)) return false;
				}
				else {
					if (abs(sorted_A(i, c) - sorted_A(j, c)) > static_cast<DerivedVector::Scalar>(abs(tolarance))) return false;
				}
			}
				
			return true;
		};

		auto unique_end = std::unique(sorted_IA.begin(), sorted_IA.end(), row_equal);

		sorted_IA.erase(unique_end, sorted_IA.end());

		IC.resize(nr, 1);

		int index = 0;
		for (int r = 0; r < nr; r++) {
			if (sorted_A.row(sorted_IA[index]) != sorted_A.row(r)) ++index;
			IC(indices_A(r)) = index;
		}

		IA.resize(sorted_IA.size());
		C.resize(IA.rows(), A.cols());

		for (int i = 0; i < IA.rows(); i++) {
			IA(i) = indices_A(sorted_IA[i]);
			C.row(i) = A.row(IA(i));
		}
	}

	template<typename DerivedVector, typename DerivedIndex>
	void uniqueRows(const Eigen::MatrixBase<DerivedVector>& A, Eigen::PlainObjectBase<DerivedVector>& C, Eigen::PlainObjectBase<DerivedIndex>& IA, Eigen::PlainObjectBase<DerivedIndex>& IC)
	{
		double tolarance = 0;
		elib::uniqueRows(A, tolarance, C, IA, IC);
	}

	template<typename DerivedVector>
	void uniqueRows(const Eigen::MatrixBase<DerivedVector>& A, Eigen::PlainObjectBase<DerivedVector>& C)
	{
		double tolarance = 0;

		Eigen::Matrix<int,Eigen::Dynamic,1> IA, IC;

		elib::uniqueRows(A, tolarance, C, IA, IC);
	}

	template<typename DerivedVector>
	void uniqueRows(const Eigen::MatrixBase<DerivedVector>& A, const double tolarance, Eigen::PlainObjectBase<DerivedVector>& C)
	{
		Eigen::Matrix<int, Eigen::Dynamic, 1> IA, IC;

		elib::uniqueRows(A, tolarance, C, IA, IC);
	}

}
