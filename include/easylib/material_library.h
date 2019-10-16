/*!
  * \headerfile material_library.h ""
  * \brief MTL is a data directory which contains examples of MTL files.
  * An MTL file is an auxiliary file containing definitions of materials that may be accessed by an OBJ file.
  * more details see https://people.sc.fsu.edu/~jburkardt/data/mtl/mtl.html
  * \author Hao Peng
  * \date 2019-10-14 
 */ 
#pragma once
#include<string>
#include<array>
namespace elib {
	template<typename T>
	class  MaterialLibrary
	{
	public:
		std::string mtl_name; //indicates that all subsequence faces should be rendered with this material, until a new material is invoked.
		std::array<T,3> Ka; //defines the ambient color of the material to be (r,g,b). The default is (0.2,0.2,0.2);
		std::array<T, 3> Kd; //defines the diffuse color of the material to be (r,g,b). The default is (0.8,0.8,0.8);
		std::array<T, 3> Ks; //defines the specular color of the material to be(r, g, b).This color shows up in highlights.The default is(1.0, 1.0, 1.0);
		T d;  //defines the non-transparency of the material to be alpha. The default is 1.0 (not transparent at all). The quantities d and Tr are the opposites of each other, and specifying transparency or non transparency is simply a matter of user convenience.
		T Tr; //defines the transparency of the material to be alpha. The default is 0.0 (not transparent at all). The quantities d and Tr are the opposites of each other, and specifying transparency or non transparency is simply a matter of user convenience.
		T Ns; //defines the shininess of the material to be s. The default is 0.0;
		T illum; //denotes the illumination model used by the material. illum = 1 indicates a flat material with no specular highlights, so the value of Ks is not used. illum = 2 denotes the presence of specular highlights, and so a specification for Ks is required.
		std::string map_Ka; //names a file containing a texture map, which should just be an ASCII dump of RGB values;

		MaterialLibrary() {
			mtl_name = "";
			Ka = { 0.2,0.2,0.2 };
			Kd = { 0.8,0.8,0.8 };
			Ks = { 1.0,1.0,1.0 };
			d = 1.0;
			Tr = 0.0;
			Ns = 0.0;
			illum = 1;
			map_Ka = " ";
		}
		MaterialLibrary(const std::string&mtl_name, const std::array<T, 3> &Ka, const std::array<T, 3> &Kd, const std::array<T, 3> & Ks, const T d, T Tr, T Ns, T illum, std::string &map_Ka) :
			mtl_name(mtl_name), Ka(Ka), Kd(Kd), Ks(Ks), d(d), Tr(Tr), Ns(Ns), illum(illum), map_Ka(map_Ka) {}

		bool operator ==(const std::string& mtl_name) const {
			return this->mtl_name == mtl_name;
		}

	};
}