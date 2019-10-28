/*!
  * \headerfile intersect_2d.h ""
  * \brief A function to compute the intersection between a ray and a 2D polygon.
  * \author Hao Peng
  * \date 2019-10-21 
 */ 
#pragma once
#include<algorithm>
#include<vector>
#include<Eigen/core>
#include "hit.h"
namespace elib {
	/*!
	  *  \fn template<typename DerivedVec,typename DerivedDetach,typename DerivedEdge>
		DerivedVec intersect2D(const Eigen::MatrixBase<DerivedVec>&source, const Eigen::MatrixBase<DerivedVec>&direction, const Eigen::MatrixBase<DerivedDetach>&detaches, const Eigen::MatrixBase<DerivedEdge>&edges);
		
	  *  \brief  A function to compute the intersection between a ray and a 2D polygon.
	  *  \param[in] source   The source point of ray
	  *  \param[in] direction   The direction of ray
	  *  \param[in] detaches   the border points of polygon
	  *  \param[out] hits   intersection points
	  *  \return DerivedVec
	 */
	template<typename DerivedVec,typename DerivedDetach>
	bool intersect2D(const Eigen::MatrixBase<DerivedVec>&source, const Eigen::MatrixBase<DerivedVec>&direction, const Eigen::MatrixBase<DerivedDetach>&detaches,std::vector<elib::Hit>&hits);

	template<typename DerivedVec, typename DerivedDetach>
	bool intersect2D(const Eigen::MatrixBase<DerivedVec>&source, const Eigen::MatrixBase<DerivedVec>&direction, const Eigen::MatrixBase<DerivedDetach>&detaches,elib::Hit&hit);
	
	template<typename DerivedVec, typename DerivedDetach>
	bool intersect2D(const Eigen::MatrixBase<DerivedVec>& source, const Eigen::MatrixBase<DerivedVec>& direction, const Eigen::MatrixBase<DerivedDetach>& detaches, std::vector<elib::Hit>&hits)
	{
		typedef typename DerivedVec::Scalar Scalar;
		typedef Eigen::Matrix<Scalar, Eigen::Dynamic, 1> VectorXv;

		const auto cross2D = [](const VectorXv& a, const VectorXv&b)->Scalar {return a(0)*b(1) - b(0)*a(1); };

		const int n = detaches.rows();

		for (int i = 0; i < n; ++i) {
			VectorXv source_ = detaches.row(i).transpose();
			VectorXv end_ = detaches.row((i + 1) % n).transpose();

			VectorXv direction_ = end_ - source_;

			VectorXv delta = source_ - source;

			Scalar prod = cross2D(direction, direction_);

			if(prod==0) continue;

			Scalar s = cross2D(delta, direction_) / prod;
			Scalar t = cross2D(delta, direction) / prod;

			if (s > 0 && t > 0 && t < 1) {
				elib::Hit hit;
				hit.id = i;
				hit.t = static_cast<double>(s);
				hits.push_back(hit);
			}
		}
		return hits.size() > 0;
	}

	template<typename DerivedVec, typename DerivedDetach>
	bool intersect2D(const Eigen::MatrixBase<DerivedVec>& source, const Eigen::MatrixBase<DerivedVec>& direction, const Eigen::MatrixBase<DerivedDetach>& detaches,elib::Hit & hit)
	{
		std::vector<elib::Hit> hits;
		elib::intersect2D(source, direction, detaches,hits);
		if(hits.empty()) return false;

		auto it = std::min_element(hits.begin(), hits.end(), [](const elib::Hit &a, const elib::Hit& b) {return a.t < b.t; });

		if (it == hits.end()) {
			return false;
		}
		else {
			hit = *it;
			return true;
		}

	}

}