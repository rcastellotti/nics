import path from "path";
import { mkdir } from "node:fs/promises";
import Shiki from "@shikijs/markdown-it";
import MarkdownIt from "markdown-it";
import matter from "gray-matter";
import { serve, $ } from "bun";
import anchor from "markdown-it-anchor";

const PORT = 9172;
const POSTS_DIR = path.resolve("./posts");
const DIST_DIR = path.resolve("./dist");

interface Post {
  slug: string;
  title: string;
  date: string;
  html: string;
}

const md = MarkdownIt();
md.use(
  await Shiki({ themes: { light: "vitesse-light", dark: "vitesse-black" } }),
);
md.use(anchor, {
  permalink: anchor.permalink.linkInsideHeader({
    symbol: "#",
    placement: "before",
  }),
});

async function getPosts(): Promise<Post[]> {
  const glob = new Bun.Glob("*.md");
  const files = await Array.fromAsync(glob.scan(POSTS_DIR));
  const posts = await Promise.all(
    files.map(async (filename) => {
      const filePath = path.join(POSTS_DIR, filename);
      const fileContent = await Bun.file(filePath).text();
      const { data, content } = matter(fileContent);
      const html = md.render(content);
      return {
        slug: filename.replace(".md", ""),
        title: data.title,
        date: data.date,
        html,
      };
    }),
  );
  return posts.sort((a, b) => {
    if (!a.date || !b.date) return 0;
    return new Date(b.date).getTime() - new Date(a.date).getTime();
  });
}

async function renderLayout(content: string) {
  const template = await Bun.file("layout.html").text();
  return template.replace("<!-- CONTENT -->", content);
}

async function renderHomePage(posts: Post[]): Promise<string> {
  const homeTemplate = await Bun.file("home.html").text();
  const list = posts
    .map(
      (p) =>
        `<li>
          <a href="/posts/${p.slug}.html">${p.title}</a>
          <span style="color: #888; font-size: 0.8em; margin-left: 10px;">${p.date ? new Date(p.date).toDateString() : ""}</span>
        </li>`,
    )
    .join("");
  const content = homeTemplate.replace("<!-- LIST -->", list);
  return renderLayout(content);
}

await mkdir(path.join(DIST_DIR, "posts"), { recursive: true });

const posts = await getPosts();
const homeHtml = await renderHomePage(posts);
await Bun.write(path.join(DIST_DIR, "index.html"), homeHtml);

for (const post of posts) {
  const postHtml = await renderLayout(post.html);
  const outputPath = path.join(DIST_DIR, "posts", `${post.slug}.html`);
  await Bun.write(outputPath, postHtml);
}

await $`cp -r public dist`;

console.log(`build complete: rsync -avzP dist/ root@10.0.0.1:/var/www/website`);
