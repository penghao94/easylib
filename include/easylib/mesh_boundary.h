/*!
  * \headerfile mesh_boundary.h ""
  * \brief Find mesh boundary
  * \author Hao Peng
  * \date 2019-10-20 
 */ 
#pragma once
#include <cstdio>
#include <vector>
#include <map>
#include "sort_rows.h"

namespace elib {
	/*!
	  *  \fn template<typename DerivedFace,typename DerivedBound>
		bool meshBoundary(const Eigen::MatrixBase<DerivedFace>&facets,const bool ccw,std::vector<Eigen::PlainObjectBase<DerivedBound>>&boundarys);
	  *  \brief  Find mesh boundarys and return its point indices
	  *  \param[in] facets   m by n lists of mesh facet indices
	  *  \param[in] ccw   iff true(default), set point indices as counter-clockwise direction, or vice versa. 
	  *  \param[out] boundarys   mesh boundarys (may be more than 1)
	  *  \return bool
	 */
	template<typename DerivedFace>
	bool meshBoundary(const Eigen::MatrixBase<DerivedFace>&facets,const bool ccw,std::vector<std::vector<int>>&boundarys);

	template<typename DerivedFace>
	bool meshBoundary(const Eigen::MatrixBase<DerivedFace>&facets, std::vector<std::vector<int>>&boundarys);


	template<typename DerivedFace>
	bool meshBoundary(const Eigen::MatrixBase<DerivedFace>& facets, const bool ccw, std::vector<std::vector<int>>&boundarys)
	{

		if (facets.cols() < 3) {
			fprintf(stderr,"Facets should have at least 3 elements in column!");
			return false;
		}

		typedef Eigen::Matrix<DerivedFace::Scalar, Eigen::Dynamic, Eigen::Dynamic> MatrixXe;

		const int nr = facets.rows();
		const int nc = facets.cols();
		MatrixXe edges(nr*nc, 2);

		//Discrete facets into edges
		for (int r = 0; r < nr; ++r) 
			for (int c = 0; c < nc; ++c) 
				edges.row(r*nc + c) << facets(r, c), facets(r, (c + 1) % nc);

		MatrixXe edges_ = edges;

		//mirror edges to sort
		for (int i = 0; i < edges_.rows(); ++i) {
			if (edges_(i, 0) > edges_(i, 1))
				std::swap(edges_(i, 0), edges_(i, 1));
		}
		
		MatrixXe sort_edges_;
		Eigen::VectorXi edges_indices_;
		elib::sortRows(edges_, sort_edges_, edges_indices_);

		const auto edge_euqal = [&sort_edges_](const int i, const int j)->bool {
			for(int c=0;c<2;++c)
				if(sort_edges_(i,c)!=sort_edges_(j,c)) return false;
			return true;
		};

		std::vector<int> unique_indices;
		
		if (!edge_euqal(0, 1)) unique_indices.push_back(0);

		for (int i = 1; i < sort_edges_.rows()-1; ++i) 
			if (!(edge_euqal(i, i - 1) || edge_euqal(i, i + 1)))
				unique_indices.push_back(i);
		
		if (!edge_euqal(sort_edges_.rows()-2, sort_edges_.rows() - 1)) unique_indices.push_back(sort_edges_.rows() - 1);
		//Find boundarys
		std::vector<std::vector<int>> boundarys_;

		std::map<int, int> edge_boundary;

		int front = -1;

		for (int i = 0; i < unique_indices.size(); i++) {
			auto edge= edges.row(edges_indices_(unique_indices[i]));
			if (front != edge(0)) {
				edge_boundary[edge(0)] = edge(1);
				front = edge(0);
			}
			else {
				boundarys_.push_back(std::vector<int>{edge(0), edge(1)});
			}
		}
		
		int ring = 0;
		while (!edge_boundary.empty()&& ring < boundarys_.size()) {
			if ( boundarys_[ring].front() == boundarys_[ring].back()) {
				++ring;
			}
			else {
				int back = boundarys_.back().back();
				boundarys_.back().push_back(edge_boundary[back]);
				edge_boundary.erase(back);
			}
		}


		while (!edge_boundary.empty()) {
			if (boundarys_.empty()||boundarys_.back().front() == boundarys_.back().back()) {
				auto it = edge_boundary.begin();
				boundarys_.push_back(std::vector<int>{it->first,it->second});
				edge_boundary.erase(it);
			}
			else {
				int back = boundarys_.back().back();
				boundarys_.back().push_back(edge_boundary[back]);
				edge_boundary.erase(back);
			}
		}

		boundarys.resize(boundarys_.size());
		for (int i = 0; i < boundarys_.size(); ++i) {

			boundarys[i].resize(boundarys_[i].size());

			int index = 0;
			if (ccw) 
				for (auto it = boundarys_[i].begin(); it != boundarys_[i].end(); ++it) boundarys[i][index++] = *it;
			else 
				for (auto it = boundarys_[i].end()-1; it != boundarys_[i].begin()-1; --it) boundarys[i][index++] =*it;
		}
		return true;
	}

	template<typename DerivedFace>
	bool meshBoundary(const Eigen::MatrixBase<DerivedFace>& facets, std::vector<std::vector<int>>& boundarys)
	{
		return elib::meshBoundary(facets, true, boundarys);
	}

}
