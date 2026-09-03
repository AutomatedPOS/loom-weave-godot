// Serve the pre-gzipped Godot wasm as gzip once.
// Workers assets would otherwise gzip it again; tablets freeze on the splash.
export default {
	async fetch(request, env) {
		const url = new URL(request.url);
		const res = await env.ASSETS.fetch(request);
		if (url.pathname !== "/index.wasm") {
			return res;
		}
		const headers = new Headers(res.headers);
		headers.set("Content-Type", "application/wasm");
		headers.set("Content-Encoding", "gzip");
		headers.set("Cache-Control", "public, max-age=0, must-revalidate, no-transform");
		headers.set("Cross-Origin-Opener-Policy", "same-origin");
		headers.set("Cross-Origin-Embedder-Policy", "require-corp");
		return new Response(res.body, {
			status: res.status,
			statusText: res.statusText,
			headers,
			encodeBody: "manual",
		});
	},
};
