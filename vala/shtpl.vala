/* 
 *  Author: Stefan Giermair (zstegi@gmail.com)
 *  License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>.
 *  This is free software: you are free to change and redistribute it. There is NO WARRANTY, to the extent permitted by law.
 */

static Regex regex1 = null;
static Regex regex2 = null;
static Regex regex3 = null;
static Regex regex4 = null;
static Regex regex5 = null;
static Regex regex6 = null;
static bool ass = false;
static bool opt = false;

static StringBuilder sb = null;

void addCache(string str) {
  if (sb.len > 0)
    sb.append("\n");
  sb.append(str);
}

void printCache() {
  if (sb.len > 0) {
    stdout.printf("printf \"%%s\\n\" \"%s\"\n", sb.str);
    sb.erase();
  }
}

void shtpl(string _file, bool raw = false, bool raw_text = false) throws GLib.Error {
  File file = File.new_for_path(_file);
  var dis = new DataInputStream(file.read());
  string line;
  while ((line = dis.read_line(null)) != null) {
    if (!raw && !raw_text && line.has_prefix("#%")) {
      if (line.has_prefix("#%include")) {
        //TODO: replace $ENVVAR with content
        shtpl(line.substring(9).strip());
      } else if (line.has_prefix("#%incraw")) {
        //TODO: replace $ENVVAR with content
        shtpl(line.substring(8).strip(), true);
      } else if (line.has_prefix("#%raw")) {
        raw_text = true;
      } else {
        if (opt)
          printCache();
        stdout.printf("%s\n", line.substring(2));
      }
      continue;
    } else if (raw_text && line.has_prefix("#%end raw")) {
      raw_text = false;
      continue;
    }

    line = regex2.replace(regex1.replace(line, -1, 0, "\\\\\\\\"), -1, 0, "\\\\\"");
    if (raw || raw_text) {
      line = regex4.replace(regex3.replace(line, -1, 0, "\\\\$"), -1, 0, "\\\\`");
    } else {
      line = regex5.replace(line, -1, 0, "\\\\$");
      if (!ass) {
        line = regex4.replace(regex6.replace(line, -1, 0, "\\\\$("), -1, 0, "\\\\`");
      }
    }

    if ( !raw && !raw_text && line.has_suffix("#slurp")) {
      if (opt)
        printCache();
      stdout.printf("printf \"%%s\" \"%s\"\n", line.substring(0, 
#if VALA_0_11
      line.char_count()-6));
#else
      line.length-6));
#endif
    } else {
      if (opt)
        addCache(line);
      else
        stdout.printf("printf \"%%s\\n\" \"%s\"\n", line);
    }
  }
}

int main (string[] args) {

  GLib.Intl.setlocale(LocaleCategory.ALL, "");

  int i = 1;
  foreach(string arg in args) {
    if (arg == "-ass" || arg == "--allow-subshell") {
      ass = true;
      i++;
    } else if (arg == "-o" || arg == "--optimize") {
      opt = true;
      i++;
    }
  }

  try {
    regex1 = new Regex("\\\\");
    regex2 = new Regex("\\\"");
    regex3 = new Regex("\\$");
    regex4 = new Regex("`");
    regex5 = new Regex("%\\$");
    regex6 = new Regex("\\$\\(");

    if (opt)
      sb = new StringBuilder();

    shtpl(args[i]);

    if (opt)
      printCache();
  } catch (Error e) {
    stderr.printf("%s\n", e.message);
    return 1;
  }

  return 0;
}
