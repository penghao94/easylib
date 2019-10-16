/*!
  * \headerfile pi.h ""
  * \brief PI
  * \author Hao Peng
  * \date 2019 - 10 - 10 
 */ 
#pragma once

namespace elib {
	// Use standard mathematical constants' M_PI if available
#ifdef M_PI
	const double PI = M_PI;
#else
	const double PI = 3.1415926535897932384626433832795;
#endif
}
