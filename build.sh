mkdir build
cd build
cp ../* .
cp -r ../py_tutorials .
find . -a -name "*.markdown" -not -name "*cn.markdown" | xargs rm -f
doxygen Doxyfile.in