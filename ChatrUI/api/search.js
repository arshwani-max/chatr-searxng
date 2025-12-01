export async function chatrSearch(query) {
    const endpoint = "http://localhost:8080/search?q=" 
                   + encodeURIComponent(query)
                   + "&format=json&engines=chatr-hybrid,mojeek,wikipedia,stackoverflow";

    const res = await fetch(endpoint);
    if (!res.ok) throw new Error(await res.text());
    return await res.json();
}
