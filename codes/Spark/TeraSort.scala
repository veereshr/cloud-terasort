package com.veeresh.terasort.spark.terasort

import com.google.common.primitives.UnsignedBytes
import org.apache.spark.SparkContext._
import org.apache.spark._
import org.apache.spark.{SparkConf, SparkContext}

object TeraSort {

  implicit val caseInsensitiveOrdering = UnsignedBytes.lexicographicalComparator

  def main(args: Array[String]) {

    val inputFile = args(0)
    val outputFile = args(1)

    val conf = new SparkConf()
      .set("spark.serializer", "org.apache.spark.serializer.KryoSerializer")
      .setAppName(s"TeraSort")
    val sc = new SparkContext(conf)

    val dataset = sc.newAPIHadoopFile[Array[Byte], Array[Byte], TeraInputFormat](inputFile)
    val sorted = dataset.partitionBy(new TeraSortPartitioner(dataset.partitions.size)).sortByKey()
    sorted.saveAsNewAPIHadoopFile[TeraOutputFormat](outputFile)
  }
}
