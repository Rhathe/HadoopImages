This is a distributed image processing program using hadoop with a frontend that uploads and displays the images using jsp. It can process images using histogram equalization and canny edge detection. The jar files HistEq.jar and EdgeDetect.jar must be included in the home folder of this project. These jar files can be compiled using the HistEq and the EdgeDetect repositories.

The arguments are: (address_of_frontend_domain, port_number,path_to_hadoop_core-site.xml,path_to_hadoop,hdfs_site.xml)
