import 'dart:io';

Future<void> main(List<String> args) async {
  // Repo name for GitHub Pages base-href: https://<user>.github.io/<repo>/
  const repoName = 'mobix-web';

  Future<void> run(String cmd) async {
    stdout.writeln('\n$cmd');
    final result = await Process.run(
      'bash',
      ['-lc', cmd],
      runInShell: true,
    );
    if (result.stdout != null) stdout.write(result.stdout);
    if (result.stderr != null) stderr.write(result.stderr);
    if (result.exitCode != 0) {
      throw Exception('Command failed (${result.exitCode}): $cmd');
    }
  }

  // 1) Clean & get deps
  await run('flutter clean');
  await run('flutter pub get');

  // 2) Build web for GitHub Pages (base-href MUST be /<repo>/)
  await run('flutter build web --release --base-href "/$repoName/"');

  // 3) Publish build/web to gh-pages branch using gh_pages package
  //    This will create/update the gh-pages branch and push it.
  await run('dart run gh_pages -d build/web -b gh-pages -r origin');

  stdout.writeln('\n✅ Deployed to GitHub Pages (gh-pages branch).');
}
