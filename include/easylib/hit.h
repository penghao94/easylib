/*!
  * \headerfile hit.h ""
  * \brief Marking hit points
  * \author Hao Peng
  * \date 2019-10-22 
 */ 
#pragma once

namespace elib {
	struct Hit
	{
		int id;// primitive id
		double u, v, w;// barycentric coordinates
		double t;// distance = direction*t to intersection
	};
}
