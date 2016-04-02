import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map.Entry;
import java.util.Scanner;
import java.util.TreeMap;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

public class SharedMemorySort {
    static TreeMap<String, ArrayList<Long>> dictionary = null;

    public static void main(String[] args) {
	try {
	    String fileName = args[0];
	    int threadCount = Integer.parseInt(args[1]);
	    Scanner input = new Scanner(new File(fileName));
	    long lineNumber = 0;
	    ArrayList<Long> lineNumbers = null;
	    long fileNumber = 0;
	    TreeMap<String, Long> mapping = new TreeMap<>();
	    BufferedWriter bwForFileSplit = null;
	    FileWriter fwForFileSplit = null;

	    while (input.hasNextLine()) {

		String readLine = input.nextLine();
		String character = readLine.substring(0, 1);
		// System.out.println(character);
		lineNumbers = new ArrayList<Long>();

		if (mapping.keySet().contains(character)) {
		    fwForFileSplit = new FileWriter(new File(mapping.get(character) + ""), true);
		    bwForFileSplit = new BufferedWriter(fwForFileSplit);
		    bwForFileSplit.write(readLine);
		    bwForFileSplit.newLine();
		    bwForFileSplit.close();

		} else {
		    mapping.put(character, fileNumber);
		    fwForFileSplit = new FileWriter(new File(fileNumber + ""), true);
		    bwForFileSplit = new BufferedWriter(fwForFileSplit);
		    bwForFileSplit.write(readLine);
		    bwForFileSplit.newLine();
		    bwForFileSplit.close();
		    fileNumber++;
		}

	    }
	    lineNumber = 0;
	    for (Entry<String, Long> entry : mapping.entrySet()) {

		// System.out.printf(lineNumber + "Key : %s and Value: %s %n",
		// entry.getKey(), entry.getValue());
		File oldFile = new File(entry.getValue() + "");
		File newFile = new File(lineNumber + "A");
		oldFile.renameTo(newFile);
		lineNumber++;
	    }

	    String[] lineRanges = new String[threadCount];
	    ExecutorService executorService = Executors.newFixedThreadPool(threadCount);

	    int totalLinesForEachThread = (int) Math.floor((int) ((lineNumber + 1) / threadCount));

	    int startLine = 0;
	    int endLine = totalLinesForEachThread;
	    for (int x = 0; x < threadCount; x++) {

		lineRanges[x] = startLine + " " + endLine;
		startLine = endLine + 1;
		endLine = startLine + totalLinesForEachThread;
		if (endLine > lineNumber) {
		    endLine = (int) lineNumber;
		}
	    }

	    long startTime = System.currentTimeMillis();
	    for (int threadNumber = 0; threadNumber < threadCount; threadNumber++) {
		SortChunks sortChunks = new SortChunks(lineRanges[threadNumber], lineNumber);
		executorService.submit(sortChunks);
	    }
	    
	    executorService.shutdown();

	    executorService.awaitTermination(24, TimeUnit.HOURS);
	    
	    
	    long endTime = System.currentTimeMillis();
	    
	    File[] files = new File[(int) (lineNumber)];
	    // System.out.println(lineNumber+"line#");
	    for (int mergeCount = 0; mergeCount < lineNumber; mergeCount++) {
		files[mergeCount] = new File(mergeCount + "B");
	    }
	    
	    File toDeleteAlreadySortedFile = new File("sortedFile");
	    toDeleteAlreadySortedFile.delete();
	    File mergedFile = new File("sortedFile");
	    mergeFiles(files, mergedFile);

	    System.out.println("Records are sorted and stored in the file named sortedFile");
	    System.out.println("Time taken for sorting "+fileName+" file using "+threadCount+" thread(s) is "+(endTime-startTime)+"ms");

	    
	    for (long temp = 0; temp < lineNumber; temp++) {
		File chunk = new File(""+temp);
		File tempA = new File(temp+"A");
		File tempB = new File(temp+"B");
		chunk.delete();
		tempA.delete();
		tempB.delete();

	    }

	} catch (FileNotFoundException e) {
	    // TODO Auto-generated catch block
	    e.printStackTrace();
	} catch (IOException e) {
	    // TODO Auto-generated catch block
	    e.printStackTrace();
	} catch (InterruptedException e) {
	    // TODO Auto-generated catch block
	    e.printStackTrace();
	}

    }

    public static void mergeFiles(File[] files, File mergedFile) {

	FileWriter fstream = null;
	BufferedWriter out = null;
	try {
	    fstream = new FileWriter(mergedFile, true);
	    out = new BufferedWriter(fstream);
	} catch (IOException e1) {
	    e1.printStackTrace();
	}

	for (File f : files) {
	    // System.out.println("merging: " + f.getName());
	    FileInputStream fis;
	    try {
		fis = new FileInputStream(f);
		BufferedReader in = new BufferedReader(new InputStreamReader(fis));

		String aLine;
		while ((aLine = in.readLine()) != null) {
		    out.write(aLine);
		    out.newLine();
		}

		in.close();
	    } catch (IOException e) {
		e.printStackTrace();
	    }
	}

	try {
	    out.close();
	} catch (IOException e) {
	    e.printStackTrace();
	}

    }

}

class SortChunks implements Runnable {

    String lineRange;
    long lineNumber;

    public SortChunks() {
	// TODO Auto-generated constructor stub
    }

    SortChunks(String lineRange, long lineNumber) {
	this.lineRange = lineRange;
	this.lineNumber = lineNumber;
    }

    static void sortChunkAndSaveToFinalFile(long startLineNumber, long endLineNumber, long line) {
	try {
	    for (; startLineNumber <= endLineNumber && startLineNumber != line; startLineNumber++) {
		File file = new File(startLineNumber + "A");
		// System.out.println("working on file "+startLineNumber+"A");
		Scanner chunk = new Scanner(file);
		int chunkLineNumber = 0;
		BufferedReader reader = new BufferedReader(new FileReader(file));
		int lines = 0;
		while (reader.readLine() != null)
		    lines++;
		int length = lines;
		// System.out.println(length);
		HashMap<String, String> keyValue = new HashMap<>();
		String[] keys = new String[length];
		while (chunk.hasNextLine()) {
		    // chunkLineNumber++;
		    String currentLine = chunk.nextLine();
		    keyValue.put(currentLine.substring(0, 10), currentLine.substring(10, 98));
		    // toSort.put(chunk.nextLine().substring(0, 10),
		    // chunkLineNumber);
		    // System.out.println();
		    chunkLineNumber++;
		}

		int temp = 0;
		for (Entry<String, String> entry : keyValue.entrySet()) {
		    keys[temp] = entry.getKey();
		    temp++;
		}

		// QuickSort.list = keys;
		QuickSort quickSort = new QuickSort();
		for (String string : keys) {
		    // System.out.println("Before " + string);
		}

		String copy[] = new String[keys.length];
		int index = 0;
		for (String string : keys) {
		    copy[index] = string;
		    index++;
		}

		quickSort.qsort(keys);

		// System.out.println("-----------------------------------");
		for (String string : keys) {
		    // System.out.println("After " + string);
		}

		// System.out.println("Key length"+keys.length);
		// System.out.println("#####");

		FileWriter fstream = new FileWriter(new File(startLineNumber + "B"), true);
		BufferedWriter out = new BufferedWriter(fstream);

		for (String key : keys) {
		    out.write(key + keyValue.get(key) + "\n");
		}

		out.close();
		// out.write(sortedWritableLine);

		// System.out.println("#####");
	    }
	} catch (FileNotFoundException e) {
	    // TODO Auto-generated catch block
	    e.printStackTrace();
	} catch (IOException e) {
	    // TODO Auto-generated catch block
	    e.printStackTrace();
	}

    }

    @Override
    public void run() {
	// TODO Auto-generated method stub
	String delims = "[ ]+";
	String[] lineNumbers = lineRange.split(delims);
	// System.out.println(lineRange);
	sortChunkAndSaveToFinalFile(Long.parseLong(lineNumbers[0]), Long.parseLong(lineNumbers[1]), lineNumber);
    }
}

class QuickSort {
    static String[] list = new String[] { "'z4P|n>\to", "-_) R'4T<\"", "-cuJvy7;=h", "-&8$lcXS$;", "-WwU4BF*P<" };

    public QuickSort() {
    }

    public void qsort(String[] list) {
	// super(list);
	quicksort(list, 0, list.length - 1);
    }

    private void quicksort(String[] list, int p, int r) {
	if (p < r) {
	    int q = partition(list, p, r);
	    if (q == r) {
		q--;
	    }
	    quicksort(list, p, q);
	    quicksort(list, q + 1, r);
	}
    }

    private int partition(String[] list, int p, int r) {
	String pivot = list[p];
	int lo = p;
	int hi = r;

	while (true) {
	    // here
	    while (list[hi].compareTo(pivot) >= 0 && lo < hi) {
		hi--;
	    }
	    while (list[lo].compareTo(pivot) < 0 && lo < hi) {
		lo++;
	    }
	    if (lo < hi) {
		String T = list[lo];
		list[lo] = list[hi];
		list[hi] = T;
	    } else
		return hi;
	}
    }

    public static void main(String[] args) {
	QuickSort quickSort = new QuickSort();
	for (String string : list) {
	    // System.out.println(string);
	}
	quickSort.qsort(list);
	// System.out.println("-----------------------------------");
	for (String string : list) {
	    // System.out.println(string);
	}
    }
}
