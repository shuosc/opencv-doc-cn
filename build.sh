git checkout master
mkdir build
cd build
cp ../* .
cp -r ../py_tutorials .
find . -a -name "*.markdown" -not -name "*cn.markdown" | xargs rm -f
find .  -name "*.jpg" -o -name "*.png" -o -name "*.bmp" | xargs -n1 -I {} cp {} ./images
doxygen Doxyfile.in
git checkout gh-pages
cp ./build/build/html/ ./