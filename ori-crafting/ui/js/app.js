// Close crafting menu
function closeCraftingMenu() {
    fetch(`https://${GetParentResourceName()}/closeCraftingMenu`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({}),
    }).then(() => {
        console.log('Crafting menu closed.');
    });
}

// Craft item
function craftItem(item) {
    fetch(`https://${GetParentResourceName()}/craftItem`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({ item: item }),
    }).then(() => {
        console.log('Crafting item:', item);
    });
}
