import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.nio.file.attribute.BasicFileAttributes;
import java.security.MessageDigest;
import java.io.*;

ArrayList<String> result = new ArrayList<String>();
ArrayList<String> filelist = new ArrayList<String>();
String keyword = ""; //Define KeyWord to search
String buildXML = "<FileHistory>\n";

void setup() {
  //fileSearch("History.txt","cat");
  //realSearch("F:\\Websrv\\Processing", "FileHistory", "zip$");

  xmlSearch("FileHistory.xml", "zip$");
} 
XML xml;
void xmlSearch(String filename, String keys) {
  xml = loadXML(filename);
  XML[] child = xml.getChildren("folder");
  deeps(child, "", keys);
  println("Result");
  for (String re : result) { // Print List of Result from Arraylist
    println(re);
  }
}
void deeps(XML[] in, String dir, String regex) {
  if (in.length > 0) {
    for (int i = 0; i < in.length; i++) {
      String dirname = in[i].getString("name");
      //println(dir);
      //println(in[i].getContent());
      XML[] cc = in[i].getChildren("file");
      for (int is = 0; is < cc.length; is++) {
        if (search(Pattern.compile(regex, Pattern.CASE_INSENSITIVE), cc[is].getContent())) {
          result.add(dir + "/"+ cc[is].getContent());
        }
      }


      deeps(in[i].getChildren("folder"), dir+"/" + dirname, regex);
      /*
    String name = children[i].getContent();
       println(id + ", " + coloring + ", " + name);
       */
    }
  } else {

    return;
  }
}
void realSearch(String rootpath, String savetofile, String keyword) {
  this.keyword = keyword;
  println(rootpath); // Print Root Path
  
  
  printlist(rootpath, 0); // Root Path Directory and Level Root Level is 0
  
  
  println("Search keyword : " + keyword);
  println("Found: " + result.size() + " Result");
  for (String re : result) { // Print List of Result from Arraylist
    println(re);
  }
  String[] fl = new String[filelist.size()];
  int i = 0;
  for (String re : filelist) { // Print List of Result from Arraylist
    fl[i] = re;
    i++;
  }
  if (savetofile != null) {
    saveStrings(savetofile + ".txt", fl);
  }
  buildXML += "\n</FileHistory>";
  //println(buildXML);
  XML xml = parseXML(buildXML);
  saveXML(xml, savetofile+".xml");
}

long lastModified(String file) {
  return new File(file).lastModified();
}

String md5(String file) {
  try {
    MessageDigest digest = MessageDigest.getInstance("MD5");
    FileInputStream fis = new FileInputStream(file);
    byte[] byteArray = new byte[1024];
    int bytesCount = 0;
    while ((bytesCount = fis.read(byteArray)) != -1) {
      digest.update(byteArray, 0, bytesCount);
    };
    fis.close();
    byte[] bytes = digest.digest();
    StringBuilder sb = new StringBuilder();
    for (int i=0; i< bytes.length; i++) {
      sb.append(Integer.toString((bytes[i] & 0xff) + 0x100, 16).substring(1));
    }
    return sb.toString();
  } 
  catch (Exception e) {
  }
  return "";
}
void fileSearch(String filename, String keyword) {
  String[] s  = loadStrings(filename);
  int i = 0;
  for (String re : s) {
    if (re.toLowerCase().indexOf(keyword.toLowerCase()) != -1) {
      //String[] res = re.split(",",2);
      result.add(re);
    }
    i++;
  }
  for (String re : result) { // Print List of Result from Arraylist
    println(re);
  }
}


void printlist(String dir, int level) {
  File file = new File(dir); 

  if (file.isDirectory()) { // Check if file is Folder
    String names[] = file.list();
    appendXML("<folder name=\"" + file.getName() + "\">");
    //println(file.getAbsolutePath());
    for (int i = 0; i < names.length; i++) {
      for (int j = 0; j < level; j++) {
        print("\t"); // Print tab level time
      }
      //println(names[i]); // print file name or directory name


      filelist.add(dir + "" + names[i]);

      if (search(Pattern.compile(keyword, Pattern.CASE_INSENSITIVE), names[i])) {
        result.add(dir + "\\" + names[i]);
      }
      /*
      if (names[i].toLowerCase().indexOf(keyword.toLowerCase()) != -1) { // use indexOf Function to Search Some String is in Other String
       result.add(dir + "\\" + names[i]); // Add File name that match to the keyword to Dynamic String Array
       }
       */
      if (!(new File(dir + "\\" + names[i])).isDirectory()) {
        String filepath =file.getAbsolutePath()+"\\" +names[i];
        File selectedfile = new File(filepath);
        String md5hash =  md5(filepath);
        println(filepath);
        println(md5hash);
        appendXML("<file size=\"" + selectedfile.length() + "\" lastModified=\"" + selectedfile.lastModified() + "\" md5=\"" + md5hash + "\" >" + names[i] + "</file>");
      }
      printlist(dir + "\\" + names[i], level+1); // Print File Tree
    }
    appendXML("</folder>");
  }
}

void appendXML(String in) {
  buildXML+=in+"\n";
}
boolean search(Pattern pattern, String strtosearch) {
  return  pattern.matcher(strtosearch).find();
}
