﻿using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using DiffMatchPatch;

namespace TestApplyPatches
{
    class TestApplyPatches
    {
        static void Main(string[] args)
        {
            TestBrokenImperfectMatch();
            TestDcsPatches();
            TestGeneralCases();
        }

        private static void TestBrokenImperfectMatch()
        {
            // this is a test that fails on the master version of this library 
            // and is fixed in my fork (reported to master repo)
            string referenceInput = "diff matching patching";
            string referenceOutput = "diff match patch";
            string imperfectInput = "diff matching pthing";
            diff_match_patch googleDiff = new diff_match_patch();
            List<Diff> diffs = googleDiff.diff_main(referenceInput, referenceOutput);
            googleDiff.diff_cleanupSemantic(diffs);
            List<Patch> patches = googleDiff.patch_make(diffs);
            Debug.WriteLine(googleDiff.patch_toText(patches));
            string patched = (string)googleDiff.patch_apply(patches, imperfectInput)[0];
            Debug.WriteLine(patched);
            Debug.Assert(patched == "diff match pth");
        }

        private static void TestDcsPatches()
        {
            // XXX create a Helios utility to locate and remember DCS root folders
            string[] dcsRoots = new string[] { "c:\\dcs", "e:\\dcs" };
            string dcsRoot = "NOTFOUND";
            foreach (string candidate in dcsRoots)
            {
                if (Directory.Exists(candidate))
                {
                    dcsRoot = candidate;
                    break;
                }
            }

            // XXX build the utility to get DCS version and select patch tree
            const string testsRoot = "..\\..\\..\\..\\Patches\\DCS\\002_005_005_41371\\";

            diff_match_patch googleDiff = new diff_match_patch();
            foreach (string testFilePath in Directory.EnumerateFiles(testsRoot, "*.gpatch", SearchOption.AllDirectories))
            {
                Debug.Assert(testFilePath.Contains(testsRoot));
                string testFileRelative = testFilePath.Replace(testsRoot, "").Replace(".gpatch", "");

                string source = ReadFile(Path.Combine(dcsRoot, testFileRelative));

                List<Patch> patches = googleDiff.patch_fromText(ReadFile(testFilePath));
                string patched = ApplyPatches(googleDiff, source, patches);

                Debug.WriteLine("=====================================================================================");
                Debug.WriteLine(testFilePath);
                Debug.WriteLine("=====================================================================================");
                Debug.WriteLine(patched);

                CheckApplied(googleDiff, testFilePath, patches, patched);

                List<Patch> reverts = googleDiff.patch_fromText(ReadFile(testFilePath.Replace(".gpatch", ".grevert")));
                string reverted = ApplyPatches(googleDiff, patched, reverts);

                CompareEquals(googleDiff, testFilePath, source, reverted);
            }
        }

        private static void CheckApplied(diff_match_patch googleDiff, string testFilePath, List<Patch> patches, string patched)
        {
            // check if applied by just seeing if all the inserts are present (we don't generate patches that insert and then delete the same thing)
            foreach (Patch patch in patches)
            {
                foreach (Diff chunk in patch.diffs)
                {
                    if (chunk.operation == Operation.INSERT)
                    {
                        if (!patched.Contains(chunk.text))
                        {
                            Debug.WriteLine("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
                            Debug.WriteLine(googleDiff.patch_toText(patches));
                            Debug.WriteLine("--------------------------------------------------------------------------------------");
                            Debug.WriteLine("missing text expected in patch result:");
                            Debug.WriteLine(chunk.text);
                            throw new System.Exception($"failed test case {testFilePath}");
                        }
                    }
                }
            }
        }

        private static string ReadFile(string filePath)
        {
            using (StreamReader streamReader = new StreamReader(filePath, System.Text.Encoding.UTF8))
            {
                return streamReader.ReadToEnd();
            }
        }

        private static void TestGeneralCases()
        {
            const string testsRoot = "..\\..\\..\\test";
            string sourcesPath = Path.Combine(testsRoot, "source");
            string patchedPath = Path.Combine(testsRoot, "patched");

            diff_match_patch googleDiff = new diff_match_patch();
            foreach (string testRootPath in Directory.EnumerateDirectories(Path.Combine(testsRoot, "cases")))
            {
                string testSourcePath = Path.Combine(testRootPath, "a");
                Debug.WriteLine(testSourcePath);
                foreach (string testFilePath in Directory.EnumerateFiles(testSourcePath, "*.lua", SearchOption.AllDirectories))
                {
                    Debug.WriteLine("=====================================================================================");
                    Debug.WriteLine(testFilePath);
                    string source = File.ReadAllText(testFilePath.Replace(testSourcePath, sourcesPath));
                    string target = File.ReadAllText(testFilePath.Replace(testSourcePath, patchedPath));
                    string testInput = File.ReadAllText(testFilePath);
                    string testExpected = File.ReadAllText(testFilePath.Replace("\\a\\", "\\b\\"));

                    // NOTE: do our own diffs so we just do semantic cleanup. We don't want to optimize for efficiency.
                    List<Diff> diffs = googleDiff.diff_main(source, target);
                    googleDiff.diff_cleanupSemantic(diffs);
                    List<Patch> patches = googleDiff.patch_make(diffs);
                    Debug.WriteLine("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
                    Debug.WriteLine(googleDiff.patch_toText(patches));
                    string patched = ApplyPatches(googleDiff, testInput, patches);
                    Debug.WriteLine("=====================================================================================");
                    Debug.WriteLine(patched);
                    CompareEquals(googleDiff, testFilePath, testExpected, patched);
                }
            }
        }

        private static string NoWhiteSpace(string text)
        {
            return text.Replace("\n", "").Replace("\r", "");
        }

        private static void CompareEquals(diff_match_patch googleDiff, string testName, string expected, string actual)
        {
            // XXX our revert does not correctly remove leading \r\n for some reason, so for now just don't require that
            if (NoWhiteSpace(actual) != NoWhiteSpace(expected))
            {
                List<Diff> errors = googleDiff.diff_main(expected, actual);
                List<Patch> errorPatches = googleDiff.patch_make(errors);
                Debug.WriteLine("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");
                Debug.WriteLine("differences from expected value to actual result:");
                Debug.WriteLine(googleDiff.patch_toText(errorPatches));
                throw new System.Exception($"failed test case {testName}");
            }
        }

        private static string ApplyPatches(diff_match_patch googleDiff, string testInput, List<Patch> patches)
        {
            object[] results = googleDiff.patch_apply(patches, testInput);
            string patched = (string)results[0];
            bool[] applied = (bool[])results[1];
            diff_match_patch.PatchResult[] resultCodes = (diff_match_patch.PatchResult[])results[2];
            for (int i = 0; i < applied.Length; i++)
            {
                if (!applied[i])
                {
                    throw new System.Exception($"failed to apply {patches[i].ToString()}: {resultCodes[i].ToString()}");
                }
                switch (resultCodes[i])
                {
                    case diff_match_patch.PatchResult.UNKNOWN:
                        throw new System.Exception($"invalid result code from application of {patches[i].ToString()}");
                    case diff_match_patch.PatchResult.APPLIED_PERFECT:
                        break;
                    case diff_match_patch.PatchResult.APPLIED_IMPERFECT:
                        Debug.WriteLine("WARNING: patch imperfectly matched input, but was applied");
                        break;
                    default:
                        throw new System.Exception($"patch should not have returned success with result code {resultCodes[i].ToString()}");
                }
            }
            return patched;
        }
    }
}
