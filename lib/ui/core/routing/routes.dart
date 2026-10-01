abstract final class Routes {
  static const landing = '/';
  static const home = '/home';
  static const signin = '/signin';
  static const signup = '/signup';
  static const createProject = '/groups/:groupId/projects/create';
  static const projectDetail = '/projects/:projectId';
  
  static const publicRoutes = [
    landing,
    signin,
    signup,
  ];
}