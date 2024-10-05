import 'package:gocv/models/resume.dart';
import 'package:gocv/providers/current_resume_provider.dart';
import 'package:gocv/providers/resume_list_provider.dart';
import 'package:gocv/providers/user_data_provider.dart';
import 'package:gocv/repositories/resume.dart';
import 'package:gocv/screens/main_screens/resume_details/resume_details_screen.dart';
import 'package:gocv/screens/main_screens/resume_preview_screen.dart';
import 'package:gocv/screens/profile_screens/profile_screen.dart';
import 'package:gocv/screens/utility_screens/settings_screen.dart';
import 'package:gocv/utils/constants.dart';
import 'package:gocv/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:gocv/widgets/dialog_helper.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = Constants.homeScreenRouteName;

  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ResumeRepository resumeRepository = ResumeRepository();

  late String userId;

  late ResumeListProvider resumeListProvider;
  late CurrentResumeProvider currentResumeProvider;

  TextEditingController titleController = TextEditingController();

  bool isLoading = true;
  bool isError = false;
  String errorText = '';

  Map<String, dynamic> newResumeData = {};

  @override
  void initState() {
    super.initState();

    resumeListProvider = Provider.of<ResumeListProvider>(
      context,
      listen: false,
    );
    currentResumeProvider = Provider.of<CurrentResumeProvider>(
      context,
      listen: false,
    );

    setState(() {
      userId = UserProvider().userData!.id.toString();
    });

    fetchResumes();
  }

  fetchResumes() async {
    print('fetch resumes');
    try {
      final response = await resumeRepository.getResumes(userId, {});

      if (response['status'] == Constants.httpOkCode) {
        final List<Resume> fetchedResumes = (response['data'] as List)
            .map<Resume>((resume) => Resume.fromJson(resume))
            .toList();
        resumeListProvider.setResumeList(fetchedResumes);
        setState(() {
          isLoading = false;
          isError = false;
          errorText = '';
        });
      } else {
        print(response);
        if (Helper().isUnauthorizedAccess(response['status'])) {
          if (!mounted) return;
          Helper().showSnackBar(
            context,
            Constants.sessionExpiredMsg,
            Colors.red,
          );
          // Helper().logoutUser(context);
        } else {
          setState(() {
            isLoading = false;
            isError = true;
            errorText = response['message'];
          });
          if (!mounted) return;
          Helper().showSnackBar(
            context,
            Constants.genericErrorMsg,
            Colors.red,
          );
        }
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        isError = true;
        errorText = 'Error fetching resumes: $error';
      });
      if (!mounted) return;
      Helper().showSnackBar(
        context,
        'Error fetching resumes',
        Colors.red,
      );
    }
  }

  createResume() async {
    try {
      final response = await resumeRepository.createResume(newResumeData);
      if (response['status'] == Constants.httpCreatedCode) {
        Resume resume = Resume.fromJson(response['data']);
        resumeListProvider.addResume(resume);

        setState(() {
          isLoading = false;
          isError = false;
          errorText = '';
        });
        if (!mounted) return;
        Navigator.pop(context);
      } else {
        if (Helper().isUnauthorizedAccess(response['status'])) {
          if (!mounted) return;
          Helper().showSnackBar(
            context,
            Constants.sessionExpiredMsg,
            Colors.red,
          );

          Helper().logoutUser(context);
        } else {
          setState(() {
            isLoading = false;
            isError = true;
            errorText = response['error'];
          });

          if (!mounted) return;
          Helper().showSnackBar(
            context,
            'Failed to create resume',
            Colors.red,
          );
        }
      }
    } catch (error) {
      if (!mounted) return;
      // Handle error
      Helper().showSnackBar(
        context,
        'Failed to create resume: $error',
        Colors.red,
      );
    }
  }

  updateResumeTitle(int index, String resumeId, String updatedTitle) async {
    try {
      final response = await resumeRepository.updateResume(
        resumeId,
        {
          'name': updatedTitle,
        },
      );

      if (response['status'] == Constants.httpOkCode) {
        setState(() {
          resumeListProvider.resumeList[index].name = updatedTitle;
        });
        if (!mounted) return;
        Navigator.pop(context);
        Helper().showSnackBar(
          context,
          'Resume title updated successfully',
          Colors.green,
        );
      } else {
        if (Helper().isUnauthorizedAccess(response['status'])) {
          if (!mounted) return;
          Helper().showSnackBar(
            context,
            Constants.sessionExpiredMsg,
            Colors.red,
          );
          Helper().logoutUser(context);
        } else {
          setState(() {
            isLoading = false;
          });
          if (!mounted) return;
          Helper().showSnackBar(
            context,
            Constants.genericErrorMsg,
            Colors.red,
          );
        }
      }
    } catch (error) {
      print('Error updating resume title: $error');
      if (!mounted) return;
      Helper().showSnackBar(
        context,
        Constants.genericErrorMsg,
        Colors.red,
      );
    }
  }

  deleteResume(int index) async {
    try {
      String resumeId = resumeListProvider.resumeList[index].id.toString();
      final response = await resumeRepository.deleteResume(resumeId);

      if (response['status'] == Constants.httpNoContentCode) {
        resumeListProvider.removeResume(index);

        setState(() {
          isLoading = false;
          isError = false;
          errorText = '';
        });
        if (!mounted) return;
        Helper().showSnackBar(
          context,
          response['message'] ?? 'Resume deleted successfully',
          Colors.green,
        );
      } else {
        if (!mounted) return;
        // Handle error
        Helper().showSnackBar(
          context,
          response['message'] ?? 'Failed to delete resume',
          Colors.red,
        );
      }
    } catch (error) {
      if (!mounted) return;
      // Handle error
      Helper().showSnackBar(
        context,
        'Failed to delete resume: $error',
        Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        title: const Text(
          Constants.appName,
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.8,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              curve: Curves.easeIn,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Image.asset(
                      //   'assets/images/logo.png',
                      //   width: 40,
                      //   height: 40,
                      // ),
                      SizedBox(width: 10),
                      Text(
                        Constants.appName,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Build Resume on the Go',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, size: 24),
              title: const Text(
                'Home',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_2_outlined, size: 24),
              title: const Text(
                'Profile',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, ProfileScreen.routeName);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.list,
                size: 24,
              ),
              title: const Text(
                'Settings',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, SettingsScreen.routeName);
              },
            ),
            ListTile(
              leading: const RotationTransition(
                turns: AlwaysStoppedAnimation(180 / 360),
                child: Icon(
                  Icons.logout,
                  color: Colors.red,
                  size: 24,
                ),
              ),
              title: const Text(
                'Logout',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Are you sure?'),
                      content: const Text('Would you like to logout?'),
                      actions: [
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: const Text('Logout'),
                          onPressed: () {
                            Helper().logoutUser(context);
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await fetchResumes();
              },
              child: isError
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            errorText,
                            style: const TextStyle(
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          ElevatedButton(
                            onPressed: () {
                              fetchResumes();
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 10.0,
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.only(bottom: 15.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey.shade100,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      showResumeAddDialog(context);
                                    },
                                    child: Container(
                                      width: width * 0.45,
                                      padding: const EdgeInsets.all(15.0),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.receipt_long),
                                          SizedBox(width: 10),
                                          Text(
                                            'New Resume',
                                            style: TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // GestureDetector(
                                  //   onTap: () {
                                  //     // Navigator.pushNamed(
                                  //     //   context,
                                  //     //   CoverLetterScreen.routeName,
                                  //     // );
                                  //   },
                                  //   child: Container(
                                  //     width: width * 0.45,
                                  //     padding: const EdgeInsets.all(15.0),
                                  //     decoration: BoxDecoration(
                                  //       color: Colors.grey.shade100,
                                  //       borderRadius:
                                  //           BorderRadius.circular(10.0),
                                  //     ),
                                  //     child: const Row(
                                  //       mainAxisAlignment:
                                  //           MainAxisAlignment.center,
                                  //       children: [
                                  //         Icon(Icons.receipt_long),
                                  //         SizedBox(width: 10),
                                  //         Text(
                                  //           'Cover Letter',
                                  //           style: TextStyle(
                                  //             fontSize: 16,
                                  //           ),
                                  //         ),
                                  //       ],
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: width,
                              child: const Text(
                                'My Resumes',
                                style: TextStyle(
                                  fontSize: 22,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: resumeListProvider.resumeList.length,
                              itemBuilder: (context, index) {
                                return resumeCard(index);
                              },
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
            ),
    );
  }

  Widget resumeCard(int index) {
    return GestureDetector(
      onTap: () {
        currentResumeProvider.setCurrentResume(
          resumeListProvider.resumeList[index],
        );
        Navigator.pushNamed(
          context,
          ResumeDetailsScreen.routeName,
        );
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: const Icon(
                Icons.receipt_long,
                color: Colors.black,
                size: 30,
              ),
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resumeListProvider.resumeList[index].name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                  const SizedBox(height: 5.0),
                  Text(
                    Helper().formatDateTime(
                      resumeListProvider.resumeList[index].createdAt!,
                    ),
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem(
                    onTap: () {
                      currentResumeProvider.setCurrentResume(
                        resumeListProvider.resumeList[index],
                      );
                      Navigator.pushNamed(
                        context,
                        ResumePreviewScreen.routeName,
                      );
                    },
                    value: 'preview',
                    child: const Text('Resume Preview'),
                  ),
                  PopupMenuItem(
                    onTap: () {
                      showResumeUpdateDialog(
                        context,
                        index,
                      );
                    },
                    value: 'update',
                    child: const Text('Update title'),
                  ),
                  PopupMenuItem(
                    onTap: () {
                      showResumeDeleteDialog(
                        context,
                        index,
                      );
                    },
                    value: 'delete',
                    child: const Text('Delete resume'),
                  ),
                ];
              },
            ),
          ],
        ),
      ),
    );
  }

  showResumeAddDialog(BuildContext context) {
    String dialogTitle = 'Create a new resume';

    Widget cancelButton = TextButton(
      child: const Text('Cancel'),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    Widget okButton = TextButton(
      child: const Text('Create'),
      onPressed: () async {
        if (titleController.text.isEmpty) {
          Helper().showSnackBar(
            context,
            'Please enter a title',
            Colors.red,
          );
          return;
        }
        setState(() {
          newResumeData['name'] = titleController.text;
          newResumeData['user'] = userId;
          isLoading = true;
        });
        titleController.clear();
        await createResume();
      },
    );

    Widget dialogContent = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          autofocus: true,
          controller: titleController,
          decoration: InputDecoration(
            hintText: 'Resume title',
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          keyboardType: TextInputType.text,
        ),
      ],
    );

    // show the dialog
    DialogHelper.showCustomDialog(
      context: context,
      title: dialogTitle,
      content: dialogContent,
      actions: [
        cancelButton,
        okButton,
      ],
    );
  }

  showResumeUpdateDialog(BuildContext context, int index) {
    String dialogTitle = 'Update resume title';

    Resume resume = resumeListProvider.resumeList[index];
    String title = resume.name;

    Widget cancelButton = TextButton(
      child: const Text('Cancel'),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    Widget okButton = TextButton(
      child: const Text('Update'),
      onPressed: () async {
        if (title.isEmpty) {
          Helper().showSnackBar(
            context,
            'Title cannot be empty',
            Colors.red,
          );
          return;
        }
        await updateResumeTitle(
          index,
          resume.id.toString(),
          title,
        );
      },
    );

    Widget dialogContent = TextFormField(
      autofocus: true,
      controller: TextEditingController(text: title),
      decoration: InputDecoration(
        hintText: 'New title',
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      keyboardType: TextInputType.text,
      onChanged: (value) {
        title = value;
      },
      validator: (value) {
        if (value!.isEmpty) {
          return 'Title cannot be empty';
        }
        return null;
      },
    );

    // show the dialog
    DialogHelper.showCustomDialog(
      context: context,
      title: dialogTitle,
      content: dialogContent,
      actions: [
        cancelButton,
        okButton,
      ],
    );
  }

  showResumeDeleteDialog(BuildContext context, int index) {
    String dialogTitle = 'Delete resume';

    // set up the button
    Widget cancelButton = TextButton(
      child: const Text('Cancel'),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    Widget okButton = TextButton(
      child: const Text(
        'Delete',
        style: TextStyle(
          color: Colors.red,
        ),
      ),
      onPressed: () {
        deleteResume(index);
        Navigator.pop(context);
      },
    );

    Widget dialogContent = const Text(
      'Are you sure about deleting this resume?\nAll the data within this resume will be lost.',
      style: TextStyle(
        color: Colors.red,
      ),
    );

    // show the dialog
    DialogHelper.showCustomDialog(
      context: context,
      title: dialogTitle,
      content: dialogContent,
      actions: [
        cancelButton,
        okButton,
      ],
    );
  }
}
