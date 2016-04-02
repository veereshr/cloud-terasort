import java.io.IOException;
import java.util.StringTokenizer;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;

public class Sorte {

	public static class KeyMapper extends Mapper<Object, Text, Text, Text> {

		private final static IntWritable one = new IntWritable(1);
		private Text k = new Text();
		private Text v = new Text();

		public void map(Object key, Text value, Context context) throws IOException, InterruptedException {
			StringTokenizer itr = new StringTokenizer(value.toString());
			String record = value.toString();
			String keyToSort = record.substring(0,10);
			String valueOfTheKey = record.substring(11);
			k.set(keyToSort);
			v.set(valueOfTheKey);
			context.write(k, v);
		}
	}

	public static class SortReducer extends Reducer<Text, Text, Text, Text> {
		private Text result = new Text();


		public void reduce(Text key, Text values, Context context) throws IOException, InterruptedException {
			result.set(values.toString());
			context.write(key, result);
		}
	}

	public static void main(String[] args) throws Exception {
		Configuration conf = new Configuration();
		conf.set("mapred.textoutputformat.separator", " ");
		Job job = Job.getInstance(conf, "Sorting Experiment");
		job.setJarByClass(Sorte.class);
		job.setMapperClass(KeyMapper.class);
		job.setCombinerClass(SortReducer.class);
		job.setReducerClass(SortReducer.class);
		job.setOutputKeyClass(Text.class);
		job.setOutputValueClass(Text.class);
		
		FileInputFormat.addInputPath(job, new Path(args[0]));
		FileOutputFormat.setOutputPath(job, new Path(args[1]));
		System.exit(job.waitForCompletion(true) ? 0 : 1);
	}
}
