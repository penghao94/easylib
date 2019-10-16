/*!
  * \headerfile levelset_interpolation.h ""
  * \brief A shape function to interpolate values.
  * \author Hao Peng
  * \date 2019 - 10 - 08
 */
#pragma once

#include<iostream>
#include<Eigen/core>

namespace elib {

	/*!
	  *  \fn bool HexahedralShapeFunction(const Eigen::PlainObjectBase<Derived>& position, const Eigen::PlainObjectBase<Derived>& corner, Eigen::PlainObjectBase<Derived>& results)
	  *  \brief  A method for Hexahedron Shape Function
	  *  \param[in] position   point position
	  *  \param[in] corner   the interpolation corner
	  *  \param[out] results    
	  *  \return bool
	 */
	template<typename Derived>
	bool HexahedralShapeFunction(
		const Eigen::PlainObjectBase<Derived> &position,
		const  Eigen::PlainObjectBase<Derived>& corner,
		Eigen::PlainObjectBase<Derived>& results);

}

template<typename Derived>
bool elib::HexahedralShapeFunction(const Eigen::PlainObjectBase<Derived>& position, const Eigen::PlainObjectBase<Derived>& corner, Eigen::PlainObjectBase<Derived>& results)
{
	typedef Eigen::Matrix<typename Derived::Scalar, Derived::RowsAtCompileTime, Derived::ColsAtCompileTime> Mat;

	if (corner.rows() != 8) {
		std::cerr << "corner rows should be 8!" << std::endl;
		return false;
	}

	Mat position_max = position.colwise().maxCoeff();
	Mat position_min = position.colwise().minCoeff();

	Mat relative_position(position.rows(), 3);
	relative_position = ((position - position_min.replicate(position.rows(), 1)).array() / (position_max - position_min).replicate(position.rows(), 1).array() * 2 - 1).matrix();

	Mat relative_corner(8, 3);
	relative_corner << -1., -1., -1., 1., -1., -1., 1., 1., -1., -1., 1., -1.,
		-1., -1., 1., 1., -1., 1., 1., 1., 1., -1., 1., 1.;

	//The shape function for the eight-node	hexahedral brick element
	Mat N(position.rows(), 8);
	for (int i = 0; i < position.rows(); i++) {
		N.row(i) = (relative_position.row(i).replicate(8, 1).array()*relative_corner.array() + 1).transpose().colwise().prod() / 8;
	}

	results = N * corner;
	return true;

}